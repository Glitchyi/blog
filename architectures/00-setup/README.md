---
title: "Setting Up The GitOps Pipeline"
description: "Bootstrapping an automated deployment pipeline for my Raspberry Pi Kubernetes blog using GitHub Actions, GHCR, and Watchtower."
post: 0
tier: 1
namespace: gitops-blog-arch
slug: setup
date: "2026-04-03"
tags: ["kubernetes", "gitops", "astro", "watchtower", "k3s"]
---

# Post 0: The Automated Architecture Blog Setup

> A frictionless GitOps pipeline pulling from GitHub Container Registry to a Raspberry Pi cluster automatically using Watchtower.

## The Problem This Solves

Writing and maintaining these architectural simulations involves a lot of trial, error, deploy, and teardown. If writing the blog posts required manually SSH-ing into the Raspberry Pi, building containers natively, and restarting pods every time a typo was fixed, the friction would kill the series before it began. A robust, set-and-forget GitOps pipeline is necessary to allow the focus to remain purely on architecture and documentation.

## Architecture Overview

This blog acts as its own architectural implementation. It is structured around the premise of local development pushed to a remote repository which seamlessly transitions into active workloads.

1. **Source of Truth**: The GitHub Repository stores all Astro code and Kubernetes manifests.
2. **Continuous Integration**: GitHub Actions listens for `push` events to the `main` branch. 
3. **Cross-Compilation**: The Action natively cross-compiles the Astro app into a minimized `linux/arm64` container.
4. **Registry**: The built artifact is stored securely in GitHub Container Registry (GHCR).
5. **Continuous Deployment**: A `watchtower` container sitting alongside the blog workload on the cluster polls GHCR and applies rolling updates automatically.

## What I'm Simulating

This simulates a lightweight, single-node GitOps lifecycle without the heavyweight overhead of full-blown ArgoCD or Flux. It's a pragmatic, developer-focused pipeline optimizing for speed and low memory footprint.

## Kubernetes Setup

### Namespace
While this project sets up the blog itself, the blog runs inside a Docker Compose stack or simple K3s deployment alongside Watchtower rather than a complex multi-pod construct.

`kubectl apply -f k8s/namespace.yaml`

### Components
- `docker-compose.yml` defining the `astro-app` and `watchtower` connection.
- `deploy.yml` handling the Action.

## What Actually Happened

One of the most immediate hurdles was image architecture. Pushing standard Docker images built on a standard CI runner resulted in immediate `exec format error` crash loops because the Raspberry Pi strictly expects `arm64` binaries, while the runner generated `amd64`. Resolving this efficiently required explicitly utilizing Docker `setup-qemu-action` combined with `buildx`, dramatically optimizing the time-to-deploy while preserving the correct architecture.

## Tradeoffs

| Strength | Weakness |
|----------|----------|
| Total automation — zero manual deploys required | Watchtower is a polling mechanism; not directly integrated with commit hooks |
| Extremely low memory overhead on the Pi | No built-in rollback logic if a faulty frontend build goes live |
| Completely private registry pulls secured seamlessly | The initial setup required manually configuring `.env` PAT tokens on the Pi |

## When to Use This (and When Not To)

This pattern perfectly fits the "Indie Developer" or "Home Lab" archetype—where you have a single compute target (like a Pi) and need highly reliable, automated sync from code to server. It quickly breaks down if you need robust canary deployments, staged rollouts, or multi-cluster synchronization. When those needs arise, an actual GitOps controller like ArgoCD becomes strictly necessary.
