# Blog

An Astro blog for writing posts from Markdown files under
`architectures/<slug>/README.md`.

The blog itself is deployed as a Docker container. GitHub Actions builds and
pushes the image to GitHub Container Registry, then triggers Watchtower on the
host so the running container updates automatically.

## Repository Structure

```text
/
├── architectures/
│   └── <slug>/
│       └── README.md          # Blog post content parsed by Astro
├── deployments/
│   └── <slug>/
│       └── README.md          # Deployment notes for the matching post
├── src/
│   ├── content.config.ts      # Astro content collection config
│   ├── pages/
│   └── styles/
├── docker-compose.yml         # Runtime services: blog + Watchtower
├── Dockerfile                 # Astro build + Nginx static serving
└── .github/workflows/deploy.yml
```

## Writing Posts

Each post lives at `architectures/<slug>/README.md` and needs frontmatter that
matches `src/content.config.ts`.

```markdown
---
title: "Post Title"
description: "Short summary for the post list."
post: 1
slug: optional-custom-slug
date: "2026-05-15"
tags: ["tier-1", "astro", "blog"]
---
```

The homepage lists posts in `post` order and can filter them by `tags`.

## Local Development

```bash
bun install
bun run dev
bun run build
```

If you use npm instead:

```bash
npm install
npm run dev
npm run build
```

## Deployment

The live deployment is Docker-based:

1. Push to `main`.
2. GitHub Actions builds `ghcr.io/glitchyi/blog:latest` for `linux/arm64`.
3. GitHub Actions pushes the image to GHCR.
4. GitHub Actions calls the Watchtower webhook.
5. Watchtower pulls the new image and recreates `astro-app`.

See [deployments/00-setup/README.md](deployments/00-setup/README.md) for the
full Watchtower and host setup.

_Built by Advaith Narayanan ([Glitchy](https://glitchy.systems/))._
