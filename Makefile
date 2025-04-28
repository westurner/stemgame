
# stemgame/Makefile
# Note that this Makefile should be unnecessary to install with devcontainer.json and Dockerfile

.PHONY=default help

_WEB:=python -m webbrowser -t

default: help

help:
	cat ./Makefile | grep '^\w'

install: aftman_install wally_install uv_install

install-wally: aftman_install
install-rojo: aftman_install

aftman_install:
	cat aftman.toml
	@echo ""
	aftman install

install-aftman:
	@echo "See the Dockerfile and devcontainer.json for how to install aftman"  # TODO  


wally_install:
	cat wally.toml
	cat wally.lock
	@echo ""
	wally install
	git --no-pager diff wally.lock

wally-install: wally_install


uv_install:
	uv venv
	uv pip install -r requirements.txt

install-uv:
	python -m ensurepip
	python -m pip install uv

jupyterlite_install:
	uv install jupyterlite

install-jupyterlite: jupyterlite_install

jupyterlite_build:
	jupyter lite --debug build

jupyterlite_serve:
	jupyter lite serve

jupyterlite_build_serve: jupyterlite_build jupyterlite_serve

open-docs-aftman:
	${_WEB} https://github.com/LPGhatguy/aftman#getting-started

open-docs-wally:
	${_WEB} https://github.com/UpliftGames/wally#commands

open-docs-rojo:
	${_WEB} https://rojo.space/docs/v7/getting-started/installation/

open-rojo-vscode-ext:
	${_WEB} https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo

open-rojo-roblox-plugin:
	${_WEB} https://www.roblox.com/library/13916111004/Rojo


rojo-vscode-ext-install:
	@echo "URL:"
	@echo "https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo"
	@echo ""
	@echo "Copy and paste this command into vscode Ctrl-P and then press Enter:"
	@echo ""
	@echo "ext install evaera.vscode-rojo"
	@echo ""

install-rojo-vscode-ext: rojo-vscode-ext-install

rojo-build:
	rojo build -o stemgame.rbxlx .

rojo-build-watch:
	rojo build --watch -o stemgame.rbxlx .

rojo-serve:
	rojo serve --address=127.0.0.1 --port 34872 . # 127.0.0.1:34872


podman-build:
	podman build . -t localhost/stemgame

podman-config-check-issues:
	set -x && cat /usr/share/containers/oci/hooks.d/oci-nvidia-hook.json

## For a system with one GPU:
# PODMAN_GPU_DEVICES= \
#		--device /dev/dri/card0 \
#		--device /dev/dri/renderD129  # 128?  ls -al /dev/dri

## For a system with two GPUs:
PODMAN_GPU_DEVICES= \
		--device /dev/dri/card0 \
		--device /dev/dri/renderD129 \
		--device /dev/dri/card1 \
		--device /dev/dri/renderD128

PODMAN_GPU_OPTS= \
		--device nvidia.com/gpu=all \
		--gpus=all \
		--hooks-dir=/etc/containers/oci/hooks.d/

PODMAN_SECURITY_OPT_LABEL=label=disable
#PODMAN_SECURITY_OPT_LABEL=label=type:container_runtime_t

#PODMAN_LOG_LEVEL=trace
PODMAN_LOG_LEVEL=debug

#PODMAN_USER=root
PODMAN_USER=appuser
PODMAN_IMAGE=localhost/stemgame
PODMAN_CMD=bash --login
PODMAN_OPTS=

PODMAN_VOLUMES_dotenv=-v ${PWD}/.env.devcontainer.sh:/.env:rw 
#PODMAN_VOLUMES_workspace=-v ${PWD}/..:/workspace 
PODMAN_VOLUMES_workspace=-v ${PWD}/../..:/workspace 
PODMAN_VOLUMES_bashhistory=-v ${VIRTUAL_ENV}/.bash_history:/home/appuser/.bash_history 
PODMAN_VOLUMES=${PODMAN_VOLUMES_dotenv} ${PODMAN_VOLUMES_workspace} ${PODMAN_VOLUMES_bashhistory} -v /etc/subuids -v /etc/subgids

PODMAN=podman

PODMAN_RM=

podman-run:
	${PODMAN} run \
		${PODMAN_OPTS} \
		--user="${PODMAN_USER}" \
		--userns=keep-id \
		--security-opt="${PODMAN_SECURITY_OPT_LABEL}" \
		--net=host \
		--ipc=host \
		--log-level="${PODMAN_LOG_LEVEL}" \
		${PODMAN_GPU_OPTS} \
		-e DISPLAY \
		-e HOME="/home/appuser" \
		${PODMAN_GPU_DEVICES} \
		${PODMAN_VOLUMES} \
		-v ${XAUTHORITY}:/root/.Xauthority:ro \
		-v ${XAUTHORITY}:/home/appuser/.Xauthority:ro \
		-v ${XAUTHORITY}:${XAUTHORITY}:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
		${PODMAN_RM} \
		-it \
		${PODMAN_IMAGE} \
		${PODMAN_CMD}

# --pid host \
# -v /proc:/proc \
#

podman-run-rm:
	$(MAKE) podman-run PODMAN_RM='--rm'

podman-run-preview:
	$(MAKE) podman-run PODMAN="echo '${PODMAN}'"

vinegar:
	$(MAKE) podman-run PODMAN_CMD="vinegar run"

CODE=code
CODE=flatpak run com.visualstudio.code
vscode:
	$(CODE) .

code: vscode
