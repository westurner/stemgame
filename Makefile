
default: help

jupyterlite_build:
	jupyter lite build

jupyterlite_serve:
	jupyter lite serve

jupyterlite_build_serve: jupyterlite_build jupyterlite_serve

_WEB:=python -m webbrowser -t
open-docs-rojo:
	${_WEB} https://rojo.space/docs/v7/getting-started/installation/

open-rojo-vscode-ext:
	${_WEB} https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo

open-rojo-roblox-plugin:
	${_WEB} https://www.roblox.com/library/13916111004/Rojo


install-rojo-vscode-ext:
	TODO https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo

podman-build:
	podman build . -t localhost/mathgame