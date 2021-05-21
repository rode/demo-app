# demo-app
This is the application repository used to demo Rode capabilities.
- The application used in the demo is a simple Express/Node app serving a `Hello World` response. [server.js](server.js)
- We build this application Docker image via Kaniko from self-hosted Kubernetes GitHub Action runners.
- After the image is built successfully in the `main` branch, it is pushed to an internal Docker registry hosted in [Harbor](https://goharbor.io/) where it will be scanned for vulnerabilities and be made available to deploy to our Kubernetes cluster.
- Immediately after pushing to the Harbor registry, we notify our GitOps deployment repository by updating its deployment manifest with the new image version.
  - This stage is executed via our GitOps GitHub Action by making a commit to the [demo-app-deployment]([https://](https://github.com/rode/demo-app-deployment)) repository.
  - The `dev` branch is updated in the destination repository, triggering a deployment via Helm to the respective `dev` environment Kubernetes namespace.
