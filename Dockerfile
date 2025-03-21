FROM fedora-toolbox:41
LABEL comment="A fedora-toolbox container for roblox development with rojo, aftman, wally, lune, stylua, selene, rbxlx-to-rojo, and cargo"

# TODO: my guess is the rust-openssl-devel and * are due to:
# > Compiling tokio-native-tls v0.3.1
# > Compiling hyper-tls v0.5.0
# > Compiling reqwest 
RUN --mount=type=cache,id=yum-cache,target=/var/cache/yum,sharing=shared \
    --mount=type=cache,id=dnf-cache,target=/var/cache/dnf,sharing=shared \
    dnf install -y cargo  \
        rust-openssl-devel openssl-devel perl-FindBin perl-IPC-Cmd perl-File-Compare perl-File-Copy && \
    dnf clean all

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo --version && \
    cargo install rojo --version ^7

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo install stylua

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo install selene

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo install aftman

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo install --git https://github.com/westurner/wally --branch patch-1 wally

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo install cargo-binstall

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo binstall lune 

RUN set -x; export cargopath='/root/.cargo/bin' && \
    grep '^export PATH="'"${cargopath}"'"' ~/.bashrc || \
    echo 'export PATH="'"${cargopath}"'":$PATH' >> ~/.bashrc; \
    source ~/.bashrc; \
    (set -x; PATH=$PATH);

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo install --git https://github.com/Striker2783/rbxlx-to-rojo rbxlx-to-rojo
    #cargo binstall --gitrbxlx-to-rojo rbxlx-to-rojo

RUN --mount=type=cache,id=cargo-cache-root,target=/root/.cargo/registry,sharing=shared \
    cargo install run-in-roblox

# TODO: mv cargo install cargo-binstall up, s/cargo install/cargo binstall/g , rm openssl build devs?
# TODO: USER 1000:1000    # what about --mount=type=cache,target=$HOME/.cargo/registry
# TODO: WORKDIR /workspace/rblx

EXPOSE 34872/tcp

CMD bash --login

