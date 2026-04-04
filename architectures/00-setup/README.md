---
title: "Setting Up The GitOps Pipeline"
description: "Bootstrapping an automated deployment pipeline for my Raspberry Pi blog using GitHub Actions, GHCR, Watchtower webhooks, and Cloudflare Tunnels."
post: 0
tier: 1
namespace: gitops-blog-arch
slug: setup
date: "2026-04-03"
tags: ["gitops", "astro", "watchtower", "docker", "cloudflare", "ai"]
---

# Post 0: The Automated Architecture Blog Setup

> A frictionless GitOps pipeline: push to `main`, GitHub builds a `linux/arm64` container, pushes it to GHCR, and webhooks a Raspberry Pi via a Cloudflare Tunnel to swap the live container in seconds.

## The Problem This Solves

Writing and maintaining these architectural simulations involves a lot of trial, error, deploy, and teardown. If publishing a blog update required manually SSH-ing into the Raspberry Pi, pulling images, and restarting containers every time a typo was fixed, the friction would kill the series before it began. A set-and-forget GitOps pipeline keeps the focus on architecture and documentation.

## Architecture Overview

The blog itself is its own architectural implementation — a complete GitOps lifecycle in miniature.

1. **Source of Truth**: The GitHub repository stores all Astro source code, Docker configuration, and architecture manifests.
2. **Continuous Integration**: GitHub Actions triggers on every `push` to the `main` branch.
3. **Cross-Compilation**: QEMU + Docker Buildx cross-compiles the Astro static site into a minimal `linux/arm64` Nginx container image.
4. **Registry**: The built image is pushed to GitHub Container Registry (GHCR) under `ghcr.io/glitchyi/blog:latest`.
5. **Webhook Trigger**: The Action fires a `POST` request to a Cloudflare Tunnel-secured endpoint, instantly waking Watchtower.
6. **Continuous Deployment**: Watchtower authenticates against GHCR, detects the new image digest, kills the old container, and starts the new one with `WATCHTOWER_STOP_TIMEOUT=0s`.

## What I'm Simulating

A lightweight, single-node GitOps lifecycle without the overhead of full ArgoCD or Flux. It trades sophistication for speed and a minimal memory footprint — pragmatic for a solo home-lab project running on a Raspberry Pi 5.

## Components

- **`Dockerfile`** — Multi-stage build: Node 22 Alpine builds the Astro site, Nginx Alpine serves the static output.
- **`docker-compose.yml`** — Defines `astro-app` (port `3002`) and `watchtower` (port `3003`).
- **`.github/workflows/deploy.yml`** — GitHub Action: checkout → QEMU → Buildx → GHCR push → Watchtower webhook.
- **Cloudflare Tunnel** — Exposes `localhost:3003` (Watchtower's HTTP API) publicly and securely without opening firewall ports.
- **`.env`** — Stores `WATCHTOWER_TOKEN` and `CR_PAT` for authentication. Never committed.

## How to Run It Yourself

```bash
# On the Raspberry Pi:
mkdir -p ~/blog && cd ~/blog
curl -sO https://raw.githubusercontent.com/Glitchyi/blog/main/docker-compose.yml
curl -s https://raw.githubusercontent.com/Glitchyi/blog/main/.env.example > .env

# Fill in WATCHTOWER_TOKEN and CR_PAT in .env, then:
echo $CR_PAT | docker login ghcr.io -u Glitchyi --password-stdin
docker compose up -d
```

## What Actually Happened

Several real problems surfaced during setup:

**Architecture mismatch.** The first deploy crashed immediately with `exec format error`. A standard GitHub Actions runner builds `amd64` images. The Raspberry Pi only runs `arm64`. Fixing this required adding `docker/setup-qemu-action` and `docker/setup-buildx-action` with `platforms: linux/arm64` explicitly declared.

**`~/.docker/config.json` was a directory.** A previous botched `docker login` left `config.json` as a directory instead of a file. Watchtower silently mounted the broken directory, couldn't parse credentials, and always returned `scanned=1 updated=0`. The fix was `sudo rm -rf ~/.docker/config.json` followed by a clean `docker login`.

**Watchtower's scope labels didn't work.** Several approaches to limiting Watchtower's scope via `WATCHTOWER_SCOPE` and `com.centurylinklabs.watchtower.enable=true` labels failed silently with different versions. The working solution was to drop scoping entirely — on a single-purpose Pi running only the blog stack, monitoring all containers is the correct default.

**Cloudflare cache served stale content.** Even after Watchtower successfully swapped the container (confirmed via logs), the live site showed old content. The culprit was Cloudflare's edge cache. A manual cache purge from the Cloudflare dashboard was required. Consider setting Cache Rules to `Bypass` for the blog tunnel hostname to prevent this.

## The Frontend Evolution (Iterative AI Enhancements)

While the initial deployment focused on hardware automation, building an aesthetically rich and highly accessible UI required significant iteration. We evolved the initial layout into a custom, dark-themed, information-dense structural aesthetic. 

Crucial custom implementations added post-launch include:
- **Responsive Layout Architecture**: Overhauled the `<main>` container boundaries shrinking `px-10` paddings down to `px-5` on mobile interfaces, and implemented aggressive `flex-wrap` and dynamic scaling on header typography (`text-3xl sm:text-4xl`) so massive architecture headlines do not abruptly wrap on older iPhones.
- **Dynamic Routing Slugs**: Replaced the default Astro folder-routing logic (`[...id].astro`) with a dynamic Zod schema loader, explicitly overriding slugs directly from the markdown frontmatter (e.g. `slug: "monolithic"`) instead of inheriting clunky nested paths like `posts/01-monolithic/readme`.
- **Advanced Markdown Injection**: Stripped the standard `@tailwindcss/typography` formatting. We reconstructed the raw `github-dark` markdown theme by defining custom child selectors `[&_pre_code]:bg-transparent` across code wrappers. This eliminated "double-layered highlighting" bugs and forced the underlying GitHub `#0d1117` `<pre>` rendering styling.
- **Dynamic Clipboard APIs**: Injected raw client-side JavaScript via Astro components directly targeting all `<pre>` bounds. This loops through code snippets, appends responsive SVG `Copy` buttons, morphs them to green checkboxes (`#4ade80`) on success, and interacts smoothly with the OS Clipboard without the necessity of bloated third-party Rehype React plugins.

## Tradeoffs

| Strength | Weakness |
|----------|----------|
| Fully automated — zero manual deploys | No rollback: a bad build goes straight to production |
| Webhook-based: updates in seconds, not minutes | Watchtower requires Pi to have outbound GHCR access |
| Cloudflare Tunnel: no open firewall ports | Cloudflare cache can serve stale HTML after updates |
| Minimal RAM footprint on the Pi | Single point of failure — one node, no redundancy |

## When to Use This (and When Not To)

This pattern is ideal for solo home-lab projects with a single compute target and no rollback requirements. It breaks down the moment you need staged rollouts, canary deployments, or multi-node synchronisation. At that point, a proper GitOps controller like ArgoCD or Flux becomes necessary.

## Resources

- [Watchtower HTTP API docs](https://containrrr.dev/watchtower/http-api-updates/)
- [Docker Buildx multi-platform builds](https://docs.docker.com/build/building/multi-platform/)
- [Cloudflare Tunnel docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
