# Blog Project Context

This repository is an Astro blog application. The blog is the primary product:
write posts, keep the site buildable, and keep deployment notes separate from
the post content.

## Project Goals

- Maintain a fast, readable Astro blog.
- Publish blog posts from Markdown files under `architectures/<slug>/README.md`.
- Keep project-specific deployment notes under `deployments/<slug>/`.
- Keep infrastructure optional and project-specific. Do not require Kubernetes,
  k3s, cluster namespaces, or manifests for normal blog publishing.

## Repository Structure

```text
blog/
├── AGENTS.md
├── README.md
├── package.json
├── astro.config.mjs
├── src/
│   ├── content.config.ts
│   ├── pages/
│   └── styles/
├── architectures/
│   └── <slug>/
│       └── README.md
├── deployments/
│   └── <slug>/
│       └── README.md
└── .github/
    └── workflows/
```

## Blog Content

The Astro content collection currently reads:

```ts
loader: glob({ pattern: '**/README.md', base: './architectures' })
```

That means each post should live at `architectures/<slug>/README.md`.

Each post must include frontmatter compatible with `src/content.config.ts`:

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

Use `tags` for topic grouping and filtering in the blog UI.

## Post Guidelines

Every post should be useful as a standalone article:

- Start with a clear title and a short framing paragraph.
- Explain the problem, context, tradeoffs, and outcome.
- Include code, commands, diagrams, or screenshots only when they help the post.
- Keep implementation notes honest: describe what worked, what failed, and what
  changed.
- Avoid turning a post into an infrastructure checklist unless the post is
  specifically about deployment.

## Deployment Notes

Use `deployments/<slug>/` for project-based deployment notes and configuration.
The deployment slug should mirror the blog post slug in `architectures/<slug>/`
when the deployment belongs to a post.

For example:

```text
architectures/00-setup/README.md
deployments/00-setup/README.md
```

Deployment folders are for docs and lightweight config by default:

- deployment notes
- environment variable examples
- platform-specific setup details
- operational runbooks
- links to workflows, compose files, or external services

Do not make any deployment platform a blog-wide requirement. Docker, static
hosting, shell scripts, managed platforms, or other tooling can be documented
per project when they are actually used.

## Current Deployment

The current repository deployment flow is Docker-based:

- GitHub Actions builds the Astro site into a container image.
- The image is pushed to GitHub Container Registry.
- Watchtower is triggered to update the running container.

Keep deployment documentation aligned with the actual workflow in
`.github/workflows/deploy.yml` and `docker-compose.yml`.

## Definition of Done

For blog content:

- Frontmatter validates against `src/content.config.ts`.
- Markdown renders cleanly in the post page.
- Links and code blocks are readable.
- `npm run build` passes.

For deployment notes:

- The matching `deployments/<slug>/README.md` exists when a post needs
  deployment context.
- Required environment variables are documented with safe example values.
- Manual steps are written as repeatable commands where possible.
- The notes describe the current deployment reality, not an intended platform
  that is not being used.

## Commands

```bash
npm run dev
npm run build
npm run preview
```

Use `npm run build` before treating a content or site change as complete.
