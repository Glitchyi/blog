# System Architecture Simulations

Exploring foundational system architectures—dynamically deployed, stress-tested, and documented on a bare-metal Kubernetes cluster.

## 🚀 Overview

This repository houses a 12-part technical blog series aimed at simulating famous structural models (Monolithic, Microservices, Event-Driven, etc.) as actual, functioning deployments on a local Kubernetes cluster. 

Each pattern gets its own simulated workload, Kubernetes manifest package, and post-mortem review detailing trade-offs, scaling behaviors, and edge-cases.

### The Stack
- **Hardware**: Raspberry Pi 5 (16GB RAM) cluster
- **Infrastructure**: k3s (Lightweight Kubernetes), Flannel/Cilium CNI, Traefik
- **Blog Engine**: Astro v6 (Static Site Generation via modern Content Layer API)
- **Styling**: Tailwind CSS v4 featuring `@tailwindcss/typography` & dark-mode styling mimicking GitHub schema.

---

## 🏗️ Repository Structure

```text
/
├── architectures/             ← Source of truth for all simulation posts and code
│   ├── 01-monolithic/
│   │   ├── k8s/               ← Namespace, deployments, services for this architecture
│   │   └── README.md          ← The write-up/blog-post parsed by Astro
│   └── ...
├── src/                       ← Astro Blog Engine
│   ├── content.config.ts      ← Glob loader map for external architectures/ folder
│   ├── pages/                 
│   │   ├── index.astro        ← Homepage with dashboard stats
│   │   └── posts/[...id].astro ← Dynamic route generator mapping K8s READMEs to URLs
│   └── styles/
└── package.json
```

---

## 🛠️ How to View the Blog Locally

This frontend is powered by [Astro](https://astro.build/). Content is automatically generated via glob loaders traversing the `architectures/` namespace.

```bash
# 1. Install dependencies (Bun recommended)
bun install

# 2. Start the local development server with hot-reload
bun run dev

# 3. Build for production (outputs to ./dist)
bun run build
```

---

## ☸️ How to Run the Infrastructure Simulations

If you want to spin up any of the architectural patterns documented in this repository onto your own cluster:

```bash
# Example: Deploying the monolithic simulation
# Always apply the namespace first
kubectl apply -f architectures/01-monolithic/k8s/namespace.yaml

# Apply the structural deployments/services
kubectl apply -f architectures/01-monolithic/k8s/

# Monitor the simulation boot process
kubectl get pods -n monolithic-arch -w
```
> **Storage Note:** Ensure persistent volumes correctly bind to external SSDs if deploying IOPS-heavy simulations. Avoid utilizing SD card boot storage for database state tracking.

---
_Built by Advaith Narayanan ([Glitchy](https://glitchy.systems/))_
