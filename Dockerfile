FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/root/.nix-profile/bin
ENV RUNNER_ALLOW_RUNASROOT true

# Install dependencies
RUN apt-get update && \
    apt-get install -y build-essential curl docker docker-compose git jq supervisor

# Install Nix
RUN mkdir -p /etc/nix && \
    echo "build-users-group =" > /etc/nix/nix.conf && \
    install -d -m755 -o $(id -u) -g $(id -g) /nix && \
    curl -L https://nixos.org/nix/install | sh

# Install Actions Runner
RUN mkdir actions-runner && cd actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v2.273.0/actions-runner-linux-x64-2.273.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64-2.273.0.tar.gz

# Set up entrypoint/cmd
WORKDIR /actions-runner

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]