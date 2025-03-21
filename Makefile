
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
