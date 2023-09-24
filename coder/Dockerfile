ARG CODER_VERSION=4.17.0
FROM codercom/code-server:${CODER_VERSION}

RUN sudo apt-get update && sudo apt-get install -y direnv gpg coreutils gcc software-properties-common apt-transport-https ca-certificates lsb-release libssl-dev pkg-config && \
    curl -L https://nixos.org/nix/install | sh