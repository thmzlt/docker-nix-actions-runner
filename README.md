# Docker Nix Actions Runner

This is a Docker image that runs a GitHub Actions self-hosted runner with Nix and a persistent volume for the Nix store.

Most CI tools discard the machine state after a successful build so developers have to manually cache artifacts in their build pipelines. By persisting the Nix store between builds, the runner only builds packages that have changed or are missing from the store.

The Nix store can be safely persisted because Nix builds packages in isolate from each other and saves the store artifacts prefixed with a hash of the build inputs.

The `entrypoint.sh` script and `supervisord.conf` files were adapted from [docker-github-runner](https://github.com/tcardonne/docker-github-runner).

## Usage

Set `GITHUB_ACCESS_TOKEN` and either `RUNNER_ORGANIZATION_URL` or `RUNNER_REPOSITORY_URL` in docker-compose.yaml and run `docker-compose up`.

## Environment Variables

THe following environment variables are used to configure the runner:

- GITHUB_ACCESS_TOKEN
- RUNNER_LABELS
- RUNNER_NAME
- RUNNER_ORGANIZATION_URL
- RUNNER_REPLACE_EXISTING
- RUNNER_REPOSITORY_URL
- RUNNER_TOKEN