#!/bin/bash
if ! which curl; then
    sudo apt install curl
fi
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if ! which uv > /dev/null 2>&1; then
    echo "uv not found on PATH — install it first: https://docs.astral.sh/uv/getting-started/installation/" >&2
    exit 1
fi

uv tool install pynvim --with "hdl-signature @ git+https://github.com/mpkopec/hdl-signature.git"
uv tool install black

health_file="$(mktemp)"
nvim --headless -c "checkhealth provider" -c "write! ${health_file}" -c "quitall"
cat "${health_file}"
rm -f "${health_file}"
