---
title: "Simulating Monolithic Architecture"
description: "The baseline every other architecture reacts to. One deployable unit, shared database, simple request-response — on a Raspberry Pi k3s cluster."
post: 1
tier: 1
namespace: monolithic-arch
slug: monolithic
date: "2026-04-05"
tags: ["kubernetes", "monolithic", "k3s", "architecture"]
---

# Post 1: Monolithic Architecture

> One single deployable unit where all application functionality logic lives together.

## The Problem This Solves

Provides a simple mental model and deployment target when starting a new application before boundaries are clear.

## Architecture Overview

All endpoints, business logic, and UI rendering (if applicable) are handled by a single application binary/process communicating with a single persistent store.

## What I'm Simulating

A single container deployment on Kubernetes that serves API responses and connects to a backend database within the same namespace.

## Kubernetes Setup

### Namespace
`kubectl apply -f k8s/namespace.yaml`

### Components
- Deployment with 1 replica
- Service exposing the deployment

### How to Run It Yourself
```bash
kubectl apply -f k8s/
kubectl get pods -n monolithic-arch
```

## What Actually Happened

*(To be filled in after the weekend deployment...)*

## Tradeoffs

| Strength | Weakness |
|----------|----------|
| Simple deploy | Blast radius |
| Less operational overhead | Slow to build over time |

## When to Use This (and When Not To)

Use for new applications, small teams. Avoid when team size or application complexity causes heavy merge conflicts or scaling bottlenecks.

## Compared to What I've Built Before

*(First post in the series!)*

## Resources

- [Monolithic Architecture](https://microservices.io/patterns/monolithic.html)
