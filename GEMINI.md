# Architecture Blog Series — Project Context

> Simulating famous system architectures on Kubernetes, documented as a blog series.
> Running on a Raspberry Pi 5 (16GB) with k3s. Managed via SSH. Blog powered by Astro.

---

## Project Goals

Build and document 12 system architecture simulations, each as a real Kubernetes deployment on a local k3s cluster. Every architecture lives in its own namespace, has its own k8s manifests, and is documented as a blog post in a co-located `README.md`. The GitHub repo is the source of truth — the Astro blog reads from it.

---

## Repository Structure

```
architecture-blog/
├── CLAUDE.md                        ← this file
├── README.md                        ← series index / landing page
├── blog/                            ← Astro project
│   ├── astro.config.mjs
│   ├── package.json
│   └── src/
│       ├── pages/
│       │   └── index.astro
│       └── content/
│           └── (symlinked or copied from architectures/)
├── architectures/
│   ├── 01-monolithic/
│   │   ├── k8s/
│   │   │   ├── namespace.yaml
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── ...
│   │   └── README.md                ← blog post content
│   ├── 02-layered/
│   │   ├── k8s/
│   │   └── README.md
│   ├── 03-client-server/
│   ├── 04-microservices/
│   ├── 05-event-driven/
│   ├── 06-soa/
│   ├── 07-cqrs/
│   ├── 08-event-sourcing/
│   ├── 09-lambda-architecture/
│   ├── 10-hexagonal/
│   ├── 11-serverless/
│   └── 12-cell-based/
```

---

## Infrastructure

### Cluster

- **Hardware**: Raspberry Pi 5, 16GB RAM
- **OS**: Raspberry Pi OS (64-bit)
- **Kubernetes**: k3s (lightweight Kubernetes)
- **Access**: SSH from dev machine, `kubectl` configured remotely
- **CNI**: Flannel (default k3s) — consider Cilium for posts 5 and 12 where network policies matter
- **Ingress**: Traefik (default k3s)
- **Storage**: local-path provisioner — always bind PVs to an external SSD, never the SD boot card

### SSH Workflow

```bash
# Copy manifests to Pi and apply
scp -r architectures/01-monolithic/k8s/ pi@raspberrypi.local:~/arch/01-monolithic/
ssh pi@raspberrypi.local "kubectl apply -f ~/arch/01-monolithic/k8s/"

# Or use kubectl with remote context
export KUBECONFIG=~/.kube/pi-config
kubectl apply -f architectures/01-monolithic/k8s/
kubectl get pods -n monolithic-arch
```

### Namespace Convention

Every architecture gets its own namespace. Apply namespace.yaml first, always.

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/          # apply remaining manifests
```

### Cleanup Between Posts

```bash
kubectl delete namespace <namespace-name>
# This removes all resources in the namespace cleanly
```

---

## Architecture Schedule

| Post | Architecture | Namespace | Weekend |
|------|-------------|-----------|---------|
| 01 | Monolithic | `monolithic-arch` | Apr 4–5 |
| 02 | Layered (N-Tier) | `layered-arch` | Apr 11–12 |
| 03 | Client-Server | `client-server-arch` | Apr 18–19 |
| 04 | Microservices | `microservices-arch` | Apr 25–26 |
| 05 | Event-Driven | `event-driven-arch` | May 2–3 |
| 06 | Service-Oriented (SOA) | `soa-arch` | May 9–10 |
| 07 | CQRS | `cqrs-arch` | May 16–17 |
| 08 | Event Sourcing | `event-sourcing-arch` | May 23–24 |
| 09 | Lambda Architecture | `lambda-arch` | May 30–31 |
| 10 | Hexagonal (Ports & Adapters) | `hexagonal-arch` | Jun 6–7 |
| 11 | Serverless | `serverless-arch` | Jun 13–14 |
| 12 | Cell-Based | `cell-based-arch` | Jun 20–21 |

---

## Blog Setup (Astro)

### Why Astro

- Static site generator — renders your markdown README files as blog posts
- Zero JS by default — fast, clean output
- Content Collections — reads from your `architectures/` folder directly
- Easy to deploy to GitHub Pages from the same repo

### Initial Setup

```bash
npm create astro@latest blog -- --template minimal
cd blog
npx astro add tailwind   # optional but recommended
```

### Content Collections Config

In `blog/src/content/config.ts`:

```typescript
import { defineCollection, z } from 'astro:content';

const architectures = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    post: z.number(),
    tier: z.number(),
    namespace: z.string(),
    date: z.string(),
    tags: z.array(z.string()).optional(),
  }),
});

export const collections = { architectures };
```

### README.md Frontmatter (use this at the top of every post)

```markdown
---
title: "Simulating Monolithic Architecture on Kubernetes"
description: "The baseline every other architecture reacts to. One deployable unit, shared database, simple request-response — on a Raspberry Pi k3s cluster."
post: 1
tier: 1
namespace: monolithic-arch
date: "2026-04-05"
tags: ["kubernetes", "monolithic", "k3s", "architecture"]
---
```

### Astro Config for Reading Architectures Folder

In `blog/astro.config.mjs`:

```javascript
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://<your-github-username>.github.io',
  base: '/architecture-blog',
  srcDir: './src',
  // Point content collections at the architectures folder
});
```

Use a symlink or Astro's `srcDir` to map `architectures/*/README.md` into content collections. Simplest approach: in `blog/src/content/architectures/`, symlink each README:

```bash
cd blog/src/content/architectures
ln -s ../../../../architectures/01-monolithic/README.md 01-monolithic.md
```

Or use a small build script to copy them before `astro build`.

---

## Blog Post Template

Every `README.md` follows this structure. Do not deviate — consistency is what makes a series feel like a series.

```markdown
---
title: ""
description: ""
post: N
tier: N
namespace: 
date: ""
tags: []
---

# Post N: [Architecture Name]

> One sentence that captures what this architecture fundamentally is.

## The Problem This Solves

What breaks or becomes painful without this architecture? What real-world scenario
demands this pattern? Keep this grounded — reference an actual company or system
if you can.

## Architecture Overview

Explain the pattern at a conceptual level. Use a diagram if it helps.
What are the key components? How do they communicate?

## What I'm Simulating

Be honest about scope. What does this simulation include, and what does it
deliberately leave out? What corners were cut to keep it a weekend project?

## Kubernetes Setup

### Namespace
`kubectl apply -f k8s/namespace.yaml`

### Components
List what you deployed: Deployments, StatefulSets, Services, ConfigMaps, Secrets, etc.

### How to Run It Yourself
```bash
kubectl apply -f k8s/
kubectl get pods -n <namespace>
# Any port-forward or ingress URLs
```

## What Actually Happened

This is the most important section. What broke? What surprised you?
What did Kubernetes add to the problem — or solve — that wouldn't be visible
in a purely local simulation?

Be specific. "The readiness probe kept failing because..." is gold.
"It worked fine" is useless.

## Tradeoffs

| Strength | Weakness |
|----------|----------|
| ... | ... |

## When to Use This (and When Not To)

What problem size or team size does this fit? What are the early warning signs
that you've outgrown it — or that you chose it too early?

## Compared to What I've Built Before

How does this differ from the previous post(s)? What carryover intuition helped,
and what previous assumption this broke?

## Resources

- Links to official docs, seminal papers, or talks that shaped your understanding
```

---

## k8s Manifest Template

Every `k8s/` folder should contain at minimum:

```
k8s/
├── namespace.yaml      ← always first
├── deployment.yaml     ← or statefulset.yaml for stateful workloads
├── service.yaml
├── configmap.yaml      ← if config is needed
└── ingress.yaml        ← if you want external access via Traefik
```

### namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <namespace-name>
  labels:
    series: architecture-blog
    post: "<post-number>"
```

### deployment.yaml (base template)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <app-name>
  namespace: <namespace-name>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: <app-name>
  template:
    metadata:
      labels:
        app: <app-name>
    spec:
      containers:
        - name: <app-name>
          image: <image>   # ensure ARM64 support
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            requests:
              memory: "64Mi"
              cpu: "50m"
            limits:
              memory: "256Mi"
              cpu: "250m"
```

**Always set resource requests and limits.** On a single-node Pi cluster, an unbounded container can starve everything else.

---

## ARM64 Image Checklist

Before using any image, verify ARM64 support:

```bash
docker manifest inspect <image>:<tag> | grep -i arm64
```

Known ARM64-compatible images for this series:

| Use case | Image |
|----------|-------|
| PostgreSQL | `postgres:16-alpine` |
| Redis | `redis:7-alpine` |
| Nginx | `nginx:alpine` |
| Kafka | `bitnami/kafka:latest` (check each version) |
| Zookeeper | `bitnami/zookeeper:latest` |
| RabbitMQ | `rabbitmq:3-management-alpine` |
| NATS | `nats:alpine` |
| App base | `node:20-alpine`, `python:3.12-slim` |

If an image has no ARM64 build: find an alternative, build your own from source, or use QEMU emulation (slow — document the tradeoff in the post).

---

## Definition of Done (Per Post)

A post is done when all of the following are true:

- [ ] Namespace created, all manifests apply without errors
- [ ] `kubectl get pods -n <namespace>` shows all pods Running
- [ ] The architecture is demonstrably working (even if minimal)
- [ ] `README.md` is written with all sections filled in
- [ ] "What Actually Happened" section has at least one real problem you hit
- [ ] Committed and pushed to GitHub

**If you are stuck on infrastructure for more than 90 minutes, work around it, note it in the post, and ship.** The blog is the deliverable.

---

## GitHub Pages Deployment

```yaml
# .github/workflows/deploy.yml
name: Deploy Blog
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: cd blog && npm ci && npm run build
      - uses: actions/deploy-pages@v4
        with:
          folder: blog/dist
```

---

## Quick Reference Commands

```bash
# Apply all manifests for a post
kubectl apply -f architectures/<post>/k8s/

# Watch pods come up
kubectl get pods -n <namespace> -w

# Tail logs
kubectl logs -n <namespace> deployment/<name> -f

# Port forward for local testing
kubectl port-forward -n <namespace> svc/<service> 8080:80

# Nuke a namespace cleanly between posts
kubectl delete namespace <namespace>

# Check resource usage on Pi
kubectl top nodes
kubectl top pods -n <namespace>

# Debug a crashlooping pod
kubectl describe pod -n <namespace> <pod-name>
kubectl logs -n <namespace> <pod-name> --previous
```

---

## Notes

- **Storage**: All PersistentVolumes must bind to the external SSD. Never use the SD card for PV data.
- **Networking**: For post 05 (Event-Driven) and post 12 (Cell-Based), consider switching CNI from Flannel to Cilium for proper NetworkPolicy support.
- **`oc` CLI**: If using OpenShift CLI (`oc`), most `kubectl` commands work as-is. `oc` adds project/namespace shortcuts.
- **k9s**: Optional but genuinely useful for monitoring pods visually over SSH. Install with `brew install k9s` or the ARM64 binary from the k9s GitHub releases.
