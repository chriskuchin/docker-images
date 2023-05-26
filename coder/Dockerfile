ARG CODER_VERSION=4.11.0
FROM codercom/code-server:${CODER_VERSION}

ARG GO_VERSION=1.20.3
ARG COCKROACH_VERSION=22.2.7
ARG NODE_VERSION=18.x
ARG INSTALL_HASHI_TOOLS="consul vault"

ENV GOPATH="/home/coder/go"
ENV VERSION=v18.15.0
ENV DISTRO=linux-x64
ENV PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:/usr/local/go/bin:/home/coder/.cargo/bin:$PATH

RUN sudo apt-get update && sudo apt-get install -y wget gpg coreutils gcc software-properties-common apt-transport-https ca-certificates curl lsb-release libssl-dev pkg-config sqlite3 && \
    sudo mkdir /keyrings && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && \
    sudo apt-get update && sudo apt-get install -y ${INSTALL_HASHI_TOOLS}

RUN wget https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -f go${GO_VERSION}.linux-amd64.tar.gz && \
    /usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest && \
    /usr/local/go/bin/go install github.com/amacneil/dbmate@latest

RUN wget -qO- https://binaries.cockroachdb.com/cockroach-v${COCKROACH_VERSION}.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v${COCKROACH_VERSION}.linux-amd64/cockroach /usr/local/bin/ && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - && \
    echo "deb https://deb.nodesource.com/node_${NODE_VERSION} $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/nodesource.list && \
    sudo apt-get update && sudo apt-get install -y nodejs && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io && \
    sudo usermod -aG docker `whoami`

RUN curl -L https://nixos.org/nix/install | sh

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y