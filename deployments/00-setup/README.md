# 00 Setup Deployment Notes

This deployment entry mirrors `architectures/00-setup/README.md`.

The current blog deployment uses:

- GitHub Actions to build and push the container image.
- GitHub Container Registry as the image registry.
- Docker Compose on the host to run the blog container and Watchtower.
- Watchtower webhook updates after a successful image push.

Keep this file focused on the live deployment workflow and operational notes.
The blog does not require a Kubernetes deployment to publish posts.
