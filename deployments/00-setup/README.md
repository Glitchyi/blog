# 00 Setup Deployment Notes

This deployment mirrors `architectures/00-setup/README.md`.

The live blog updates automatically through this flow:

1. A commit is pushed to `main`.
2. `.github/workflows/deploy.yml` builds `ghcr.io/glitchyi/blog:latest`.
3. The workflow pushes the image to GitHub Container Registry.
4. The workflow calls the Watchtower HTTP webhook.
5. Watchtower pulls the new image and recreates `astro-app`.

The blog does not require Kubernetes, k3s, namespaces, or manifests to publish
posts.

## Host Requirements

- Docker Engine with the Compose plugin.
- A GitHub personal access token that can read the GHCR image.
- A Cloudflare Tunnel or another HTTPS endpoint that can reach Watchtower on the
  host.
- A random Watchtower webhook token.

## Environment File

Create `/home/glitchy/blog/.env` on the host:

```bash
WATCHTOWER_TOKEN="replace-with-a-long-random-token"
CR_PAT="ghp_replaceWithGitHubPackageReadToken"
```

`WATCHTOWER_TOKEN` must match the GitHub Actions secret with the same name.
`CR_PAT` is used for authenticating Docker to GHCR on the host.

The repository also includes `.env.example` with safe placeholder values.

## GHCR Login

Watchtower can only pull private GHCR images if Docker is already logged in.
Run this on the host:

```bash
echo "$CR_PAT" | docker login ghcr.io -u Glitchyi --password-stdin
```

Confirm that Docker created a regular file at `/home/glitchy/.docker/config.json`:

```bash
test -f /home/glitchy/.docker/config.json
```

If that path is accidentally a directory, Watchtower will not read credentials
correctly. Fix it before starting Compose:

```bash
rm -rf /home/glitchy/.docker/config.json
echo "$CR_PAT" | docker login ghcr.io -u Glitchyi --password-stdin
```

## Docker Compose

Start the stack from the repository root:

```bash
cd /home/glitchy/blog
docker compose up -d
```

The current `docker-compose.yml` runs:

- `astro-app`: serves `ghcr.io/glitchyi/blog:latest` on host port `3002`.
- `watchtower`: exposes the HTTP API on host port `3003`.

Watchtower mounts:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
  - /home/glitchy/.docker/config.json:/config.json
```

The `/config.json` mount lets Watchtower use the GHCR login created above.

## GitHub Actions Secrets

Configure these repository secrets:

```text
WATCHTOWER_TOKEN=replace-with-the-same-token-from-.env
WATCHTOWER_URL=https://your-watchtower-webhook-hostname
```

`WATCHTOWER_URL` should point at the public HTTPS endpoint that forwards to
Watchtower's local port `3003`. The workflow appends `/v1/update`, so the final
request is:

```text
POST $WATCHTOWER_URL/v1/update
Authorization: Bearer $WATCHTOWER_TOKEN
```

## Cloudflare Tunnel Example

If using Cloudflare Tunnel, route a private hostname to Watchtower:

```text
https://your-watchtower-webhook-hostname -> http://localhost:3003
```

Then set `WATCHTOWER_URL` to:

```text
https://your-watchtower-webhook-hostname
```

## Manual Update Test

After pushing a new image to GHCR, trigger Watchtower manually:

```bash
curl -X POST \
  -H "Authorization: Bearer $WATCHTOWER_TOKEN" \
  http://localhost:3003/v1/update
```

Expected result: Watchtower scans the image, pulls a newer digest when one
exists, and recreates `astro-app`.

Check status:

```bash
docker ps
docker logs --tail 100 watchtower
docker logs --tail 100 astro-app
curl -I http://localhost:3002
```

## Important Operational Notes

- Local `docker build -t ghcr.io/glitchyi/blog:latest .` is useful for testing,
  but it does not publish the image to GHCR. Watchtower updates from the registry,
  so automatic production updates should come from the GitHub Actions workflow.
- If the live site appears stale after Watchtower updates the container, purge or
  bypass the Cloudflare cache for the blog hostname.
- The current setup does not implement rollback. A bad image pushed to `latest`
  can become live immediately after the webhook runs.
