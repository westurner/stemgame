FROM fedora-toolbox:41
LABEL comment="A fedora-toolbox container for roblox development with rojo, aftman, wally, lune, stylua, selene, rbxlx-to-rojo, and cargo"

# TODO: are rust-openssl-devel and * necessary due to:
# > Compiling tokio-native-tls v0.3.1
# > Compiling hyper-tls v0.5.0
# > Compiling reqwest 
ENV apphome="/home/appuser"
USER root
RUN --mount=type=cache,id=yum-cache,target=/var/cache/yum,sharing=shared \
    --mount=type=cache,id=dnf-cache,target=/var/cache/dnf,sharing=shared \
    dnf install -y cargo  \
        rust-openssl-devel openssl-devel perl-FindBin perl-IPC-Cmd perl-File-Compare perl-File-Copy && \
    dnf clean all

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    useradd -u 1000 -F -s /bin/bash -U -m -d "${apphome}" appuser && \
    chown -Rv appuser:appuser "${apphome}"

USER appuser
RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    mkdir -p ~/.cargo && \
    ls -al $HOME/.cargo/ $HOME/.cargo/registry

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    (set -x; id -u && \
    ls -al ~/.cargo/ && \
    cargo --version && \
    cargo install rojo --version ^7)

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    cargo install stylua

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    cargo install selene

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    cargo install aftman

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    cargo install --git https://github.com/westurner/wally --branch patch-1 wally

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    cargo install cargo-binstall

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    cargo binstall lune 

# RUN set -x; export cargopath='${apphome}/.cargo/bin' && \
#     grep '^export PATH="'"${cargopath}"'"' ~/.bashrc || \
#     echo 'export PATH="'"${cargopath}"'":$PATH' >> ~/.bashrc; \
#     source ~/.bashrc; \
#     (set -x; PATH=$PATH);

RUN set -x; echo -e "\n\n### source .env\nsource /.env\n# " >> ~/.bashrc

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,sharing=shared \
    cargo install --git https://github.com/Striker2783/rbxlx-to-rojo rbxlx-to-rojo
    #cargo binstall --git rbxlx-to-rojo rbxlx-to-rojo

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,sharing=shared \
    cargo install run-in-roblox

# TODO: mv cargo install cargo-binstall up, s/cargo install/cargo binstall/g , rm openssl build devs?


# RUN --mount=type=cache,id=dnf-cache,target=/var/cache/dnf,sharing=shared \
#     --mount=type=cache,id=protonge-cache,target=${apphome}/.local/protonge,sharing=shared \
#     export dstpath="$HOME/.steam${apphome}/compatibilitytools.d" && \
#     export protonge="${HOME}/.local/protonge" && \
#     mkdir -p "$dstpath" && \
#     mkdir -p "$protonge" && \
#     cd ~/.local/protonge && \
#     bash -x "$(type -p updatePGEfast.sh)"

# RUN --mount=type=cache,id=pip-cache,target=${apphome}/.cache/pip,sharing=shared \
#     dnf install -y python3-pip pipx  && \
#     pipx install protonup && \
#     mkdir -p ~/.cache/pip/protonup

# RUN --mount=type=cache,id=pip-cache,target=${apphome}/.cache/pip,sharing=shared \
#     cd ~/.cache/pip/protonup && ~/.local/bin/protonup -y -o ~/.cache/pip/protonup && \
#     ~/.local/bin/protonup -l

USER root
RUN --mount=type=cache,id=yum-cache,target=/var/cache/yum,sharing=shared \
    --mount=type=cache,id=dnf-cache,target=/var/cache/dnf,sharing=shared \
    dnf copr enable -y thegu5/vinegar && \
    dnf install -y \
        vinegar \
        xdg-utils \
        cairo gdk-pixbuf2 graphene pango gtk4 libadwaita adw-gtk3-theme \
        libglvnd-gles egl-wayland \
        && \
    dnf clean all

USER appuser:appuser
RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    cargo install protonup-rs

## mkdir -p ~/.local/share/lutris/runners/wine/ && \

RUN --mount=type=cache,id=cargocache,target=${apphome}/.cargo/registry,uid=1000,sharing=shared \
    --mount=type=cache,id=protonup-cache-root,target=${apphome}/.protonup,uid=1000,sharing=shared \
    mkdir -p ~/.steam/steam/compatibilitytools.d/ && \
    cd ~/.protonup && \
    ~/.cargo/bin/protonup-rs -q -f

ENTRYPOINT ["/entrypoint.sh"]
USER root
COPY .env.devcontainer.sh /.env
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER appuser:appuser
RUN \
    SETUP_WEBVIEW2=1 bash /.env 

# TODO: this would be compatible with devcontainers 
#  WORKDIR /workspace/stemgame
#  WORKDIR /workspace  #?

# NOTE: Because of the required GUI login, `vinegar run` (which installs RobloxStudio.exe)
# must be run in a postBuild action run within each container instance
#
# 
#
# RUN --mount=type=cache,id=vinegar-cache,target=${apphome}/.cache/vinegar,sharing=shared \
#     --mount=type=cache,id=protonge-cache,target=${apphome}/.local/protonge,sharing=shared \
#     vinegar run

# rojo serve
EXPOSE 34872/tcp
# run-in-roblox
EXPOSE 50312/tcp

# TODO: sed s,${apphome},/home/$DEV_USERNAME,g ./Dockerfile
# USER $DEV_UID:$DEV_GID
# WORKDIR /home/$DEV_USERNAME
# RUN umask

CMD bash --login

