ARG CODER_VERSION=4.13.0
FROM codercom/code-server:${CODER_VERSION}

RUN sudo apt-get update && sudo apt-get upgrade && sudo apt-get install -y curl && \
    curl -L https://nixos.org/nix/install | sh