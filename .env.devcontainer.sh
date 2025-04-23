#!/usr/bin/env bash

_this=$0


###
PATH_prepend () {
  # PATH_prepend()     -- prepend a directory ($1) to $PATH
    #   instead of:
    #       export PATH=$dir:$PATH
    #       PATH_prepend $dir 
    # http://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there/39840#39840
    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH="${1}:${PATH}"
}


PATH_append () {
  # PATH_append()     -- append a directory ($1) to $PATH
    #   instead of:
    #       export PATH=$PATH:$dir
    #       PATH_append $dir 
    # http://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there/39840#39840
    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH="${PATH}:${1}"
}
###


setup_homelocal_PATH() {
    PATH_prepend "${HOME}/.local/bin"
}

setup_cargo_PATH() {
    export PATH_cargo="${PATH_cargo:-"${HOME}/.cargo/bin"}"
    PATH_prepend "${PATH_cargo}"
}

setup_proton_PATH() {
    export PATH_steam="${PATH_steam:-"${HOME}/.steam"}"
    export PATH_proton="${PATH_proton:-"${PATH_steam}/steam/compatibilitytools.d/GE-Proton9-26"}"
    export PATH_proton_bin="${PATH_proton_bin:-"${PATH_proton}/files/bin"}"
    # default: "${HOME}/.steam/steam/compatibilitytools.d/GE-Proton9-26/files/bin"
    PATH_append "${PATH_proton_bin}"
}

setup_WINEPREFIX_proton() {
    if [ -n "${VINEGAR_USE_FLATPAK}" ]; then
        export VINEGAR_FLATPAK="${VINEGAR_FLATPAK:-"${HOME}/.var/app/org.vinegarhq.Vinegar"}"
        export WINEPREFIX_PROTON="${WINEPREFIX_PROTON:-"${VINEGAR_FLATPAK/data/vinegar/prefixes/studio}"}"
    else
        export WINEPREFIX_PROTON="${WINEPREFIX_PROTON:-"${HOME}/.local/share/vinegar/prefixes/studio"}"
    fi
    export WINEPREFIX="${WINEPREFIX:-${WINEPREFIX_PROTON}}"
    export WINEPREFIX_AppData="${WINEPREFIX}/drive_c/users/steamuser/AppData"
}

setup_WINE_and_WINEARCH () {
    export WINE="${WINE:-"${PATH_proton_bin:-"${HOME}/.local/bin"}/wine64"}"
    export WINEARCH="${WINEARCH:-"win64"}"
}

gpg_verify() {
    local path=$1
    if [ -z "$(type -p gpg)" ]; then
        echo "ERROR: 'gpg' must be on PATH" >&2
        (set -x; PATH=$PATH)
        return 2
    fi
    gpg --verify "${path}"
}

setup_winetricks() {
    release_date="${WINETRICKS_RELEASE:-"20250102"}"

    if [ -e "${HOME}/.local/bin/winetricks" ]; then
        echo "INFO: ~/.local/bin/winetricks already exists. To run setup_winetricks, delete it first."
        return
    fi

    archive_unpack_path="${HOME}/winetricksinstall"
    archive_path="${archive_unpack_path}/winetricks-${release_date}"

    #url1="https://github.com/Winetricks/winetricks/releases/download/20250102/20250102.tar.gz.asc"
    url1="https://github.com/Winetricks/winetricks/releases/download/${release_date}/${release_date}.tar.gz.asc"
    url1_filename="$(basename "$url1")"
    url2="https://github.com/Winetricks/winetricks/archive/refs/tags/${release_date}.tar.gz"
    url2_filename="$(basename "$url2")"

    mkdir -p "${archive_unpack_path}"

    (cd "${archive_unpack_path}" || return 1;
    test -f "${url1_filename}" || \
        curl -fSsL "${url1}" -o "${url1_filename}";
    test -f "${url2_filename}" || \
        curl -fSsL "${url2}" -o "${url2_filename}";
    gpg_verify "${url1_filename}";
    tar -xzvf "${url2_filename}" -C "${archive_unpack_path}";)

    # TODO:
    export WINETRICKSPATH="${WINETRICKSPATH:-"${archive_unpack_path}"}"
    if [ -z "${WINETRICKSPATH}" ] || [ -z "${WINE}" ]; then
        echo "WINETRICKSPATH and WINE must be set:" >&2
        (set -x; WINETRICKSPATH=${WINETRICKSPATH}; WINE=${WINE})
        return 2
    fi

    WINE="${WINE}" WINEARCH="${WINEARCH}" \
        make -C "${archive_path}" install PREFIX="${HOME}/.local"

    WINE="${WINE}" WINEARCH="${WINEARCH}" \
        ~/.local/bin/winetricks arch=64 prefix="${WINEPREFIX_PROTON}"

    # TODO: how to call wine64
}

dia_prime() {
    # source: "prime-run" script
    export __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia
    _nvidia_smi=$(test -p "nvidia-smi")
    if [ -z "${_nvidia_smi}" ]; then
        echo "INFO: nvidia-smi not found."
        (set -x; PATH=$PATH)
        echo "INFO: Also, check that /dev/dri/card and /dev/dri/render are available:"
        (set -x; ls -al /dev/dri/card* /dev/dri/render*)
        return
    fi
}

unsetup_nvidia_prime() {
    export __NV_PRIME_RENDER_OFFLOAD='' __VK_LAYER_NV_optimus='' __GLX_VENDOR_LIBRARY_NAME=''
}

setup_webview2() {
    export SKIP_WEBVIEW_DOWNLOAD=${SKIP_WEBVIEW_DOWNLOAD:-""}
    export WEBVIEW2_VERSION=${WEBVIEW2_VERSION:-"133.0.3065.92"}
    export WEBVIEW2_ARCH=${WEBVIEW2_ARCH:-"x64"}
    # export WEBVIEW2_ARCH="x86"
    # export WEBVIEW2_ARCH="arm64"
    export WEBVIEW2_FILENAME=${WEBVIEW2_FILENAME:-"Microsoft.WebView2.FixedVersionRuntime.${WEBVIEW2_VERSION}.${WEBVIEW2_ARCH}.cab"}
    export WEBVIEW2_URL=${WEBVIEW2_URL:-"https://github.com/westinyang/WebView2RuntimeArchive/releases/download/${WEBVIEW2_VERSION}/${WEBVIEW2_FILENAME}"}
    export WEBVIEW2_DOWNLOADS=${WEBVIEW2_DOWNLOADS:-'.'}
    export WEBVIEW2_FILEPATH=${WEBVIEW2_FILEPATH:-"${WEBVIEW2_DOWNLOADS}/${WEBVIEW2_FILENAME}"}

    if [ -z "${SKIP_WEBVIEW_DOWNLOAD}" ] && [ ! -f "${WEBVIEW2_FILEPATH}" ]; then
        curl -fSsL "${WEBVIEW2_URL}" -o "${WEBVIEW2_FILENAME}"
    fi
    # TODO: cabextract "${WEBVIEW2_FILEPATH}" ---output-path=$
}


### DPI setting

leftpad_hex () {
    local hexintstr=$1
    hex_str=$(printf "%8s" "$(printf "%x" "${hexintstr}")" | tr ' ' '0')
}

generate_valid_font_dpi() {
    (set +x;
    for n in $(seq 8 41); do
        n=$((12*"${n}"));
        #echo "${n}" "$(printf "0x000000%x\n" "${n}")";
        echo "${n}" "$(printf "%8s" "$(printf "%x" "${integer_str}")" | tr ' ' '0')"
    done)
}

is_valid_wine_font_dpi() {
    local dpi=$1
    test "$(("${dpi}"%12))" -eq 0
    local retcode=$?
    if [ "${retcode}" -gt 0 ]; then
        echo "ERROR: dpi=$dpi is not a valid_wine_font_dpi"
    fi
    return "${retcode}"
}

# echo "${_valid_values}" | tr ' ' '\n' | grep -qq -E "^${_str}$" <(echo "${_valid_values}")

generate_dword_hex_from_int() {
    local _str=$1
    # 96 108 120 132 144 156 168 180 192 ... 480

    if [ -z "${__SKIP_DWORD_VALUE_VALUE_CHECK}" ]; then
        is_valid_wine_font_dpi "${_str}"
        _retcode=$?
        if [ "${_retcode}" != 0 ]; then
            echo "ERROR: \$1=${_str} is not divisible by 12" >&2
            generate_valid_font_dpi >&2
            return "${_retcode}"
        fi
    fi

    _hex_val="$(cast_int_to_dword "${_str}")"
    echo "${_hex_val}"
}

cast_int_to_dword() {
    local integer_str=$1
    local hex_str=
    local retcode=
    hex_str=$(printf "%8s" "$(printf "%x" "${integer_str}")" | tr ' ' '0')
    retcode=$?
    if [ 0 -eq "${retcode}" ]; then
        echo "${hex_str}"
        return 0
    else
        echo "ERROR: cast_int_to_dword retcode=$retcode" >&2
        return "${retcode}"
    fi
}

cast_hex_to_int() {
    local hexint=$1
    echo "$((0x$hexint))"
    return
}

test_generate_dword_hex_from_int() {
    _test() {
        local input_int="${1}"
        local expected_str="${2}"
        local retcodes=0

        output=$(generate_dword_hex_from_int "${input_int}")
        if [ "${output}" == "${expected_str}" ]; then
            echo "TESTPASS: generate_dword_hex_from_int ${input_int}"
        else
            echo "TESTFAIL: generate_dword_hex_from_int ${input_int} => ${output} != ${expected_str}" >&2
            retcodes=$((retcodes+4))
        fi

        output2=$(cast_hex_to_int "${output}")
        if [ "${output2}" == "${input_int}" ]; then
            echo "TESTPASS: cast_hex_to_int ${output} => ${output2} == ${input_int}" >&2
        else
            echo "TESTFAIL: cast_hex_to_int ${output} => ${output2} != ${input_int}" >&2
            retcodes=$((retcodes+8))
        fi
        return "${retcodes}"
    }

    __SKIP_DWORD_VALUE_VALUE_CHECK=1
    _test 0   "00000000"
    _test 1   "00000001"
    _test 16  "00000010"
    _test 33  "00000021"
    __SKIP_DWORD_VALUE_VALUE_CHECK=
    _test 144 "00000090"
    _test 168 "000000a8"
}

setup_WINEPREFIX_USERREG() {
    test -n "${WINEPREFIX}" || setup_WINEPREFIX_proton
    export WINEPREFIX_USERREG="${WINEPREFIX_USERREG:-"${WINEPREFIX}/user.reg"}"
}

get_wine_dpi_logpixels_str() {
    if [ ! -n "${WINEPREFIX_USERREG}" ]; then
        setup_WINEPREFIX_USERREG
    fi
    if [ ! -f "${WINEPREFIX_USERREG}" ]; then
        echo "ERROR: WINEPREFIX_USERREG=${WINEPREFIX_USERREG} not found" >&2
        return 2
    fi
    output=$(grep '^"LogPixels"=dword:' "${WINEPREFIX_USERREG}" | cut -f 2 -d ':')
    local retcode=$?
    echo "${output}"
    return "${retcode}"
    # "LogPixels"=dword:000000a8
}

get_wine_dpi_int() {
    _dword_str=$(get_wine_dpi_logpixels_str | sed 's,.*=dword:\(.*\),\1,')
    _dpi_int=$(cast_hex_to_int "${_dword_str}")
    echo "${_dpi_int}"
    return
}

assert_dpi_is() {
    expected_value=$1
    output=$(get_wine_dpi_int)
    if [ "${output}" != "${expected_value}" ]; then
        echo "ERROR: get_wine_dpi_int: $1 => $output != ${expected_value}"
        return 1
    fi
    return 0
}

setup_wine_dpi() {
    dpi=$1
    commit=0
    dwordstr='"LogPixels"=dword:'"$(generate_dword_hex_from_int "${dpi}")"
    echo "### setup_wine_dpi changes:" >&2
    (set -x; get_wine_dpi_logpixels_str | sed 's,^"LogPixels"=dword:.*$,'"${dwordstr}"',g')
    test -n "${WINEPREFIX_USERREG}" || setup_WINEPREFIX_USERREG
    if [ -n "${commit}" ]; then
        sed -i 's,^"LogPixels"=dword:,'"${dwordstr}"',g' "${WINEPREFIX_USERREG}"
        return
    else
        echo "INFO: Not comitting. commit=$commit"
        return
    fi
}

test_setup_wine_dpi() {
    if [ ! -n "${WINEPREFIX_USERREG}" ]; then
        setup_WINEPREFIX_USERREG
    fi
    if [ ! -f "${WINEPREFIX_USERREG}" ]; then
        echo "ERROR: WINEPREFIX_USERREG=${WINEPREFIX_USERREG} not found" >&2
        return 2
    fi

    existing_dpi=$(get_wine_dpi_int)
    assert_dpi_is 96  # default

    setup_wine_dpi  144
    assert_dpi_is 144

    setup_wine_dpi  196
    assert_dpi_is 196

    setup_wine_dpi "${existing_dpi}"
    assert_dpi_is "${existing_dpi}"
}

### </end dpi setting> 

export STUDIO_CLIENT_SETTINGS="${WINEPREFIX_AppData}/Local/Roblox/ClientSettings/ClientAppSettings.json"
#export STUDIO_APP_SETTINGS="${WINEPREFIX_AppData}/Local/Roblox/ClientSettings/StudioAppSettings.json"
#TODO: PR
function setup_roblox_studio_for_legacy_jest_tests() {
    local client_app_settings="${STUDIO_CLIENT_SETTINGS}"
    if [ -n "${client_app_settings}" ]; then
        #jq '.FFlagEnableLoadModule=true' "${studio_app_settings}" > ${studio_app_settings}.date.new
        #sed -i 's/"FFlagEnableLoadModule":false/"FFlagEnableLoadModule":true/g' "${client_app_settings}"
        echo '{"FFlagEnableLoadModule": true}' > "${client_app_settings}"
        cat "${client_app_settings}" | grep "FFlagEnableLoadModule"
        return
    else
        echo "ERROR: STUDIO_CLIENT_SETTINGS=$STUDIO_CLIENT_SETTINGS"
        return 2
    fi
}

function setup_roblox_studio_for_legacy_jest_tests__local() {
    (set -x; export STUDIO_CLIENT_SETTINGS="${HOME}/.var/app/org.vinegarhq.Vinegar/data/vinegar/prefixes/studio/drive_c/users/steamuser/AppData/Local/Roblox/ClientSettings/ClientAppSettings.json";
    setup_roblox_studio_for_legacy_jest_tests)
}

setup_WINEPREFIX_SYMLINK() {
    export WINEPREFIX_SYMLINK="${WINEPREFIX_SYMLINK:-"${HOME}/wineprefix64"}" 
    if [ ! -e "${WINEPREFIX_SYMLINK}" ]; then
        ln -s "${PATH_proton_bin}" "${WINEPREFIX_SYMLINK}"
    fi
    
}


function setup_vinegar_config() {
    vinegar_cfg="${HOME}/.config/vinegar/config.toml"
    cat >> "${vinegar_cfg}" << EOF

# This enables dxvk:
dxvk=true

# This machine has an iGPU and an NVIDIA dGPU:
gpu="prime-discrete"


# FFlagEnableLoadModule is necessary for jest-lua tests to run
# until https://github.com/Roblox/jest-roblox/blob/master/CHANGELOG.md#3100-2024-10-02 is merged into jsdotlua/jest-lua IIUC:
[studio.fflags]
FFlagEnableLoadModule=true'
EOF

}

_test_all() {
    if [ -z "${__TESTCONTINUE}" ]; then
        set -e
    fi
    (set -x; test_generate_dword_hex_from_int)
    (set -x; test_setup_wine_dpi)
}

setup_devcontainer_main() {
    export SETUP_PRIME=${SETUP_PRIME:-"1"}
    export SETUP_WEBVIEW2=${SETUP_WEBVIEW2:-""}
    export SETUP_WINETRICKS=${SETUP_WINETRICKS:-"1"}

    setup_homelocal_PATH

    setup_cargo_PATH

    if [ -n "${SETUP_PRIME}" ]; then
        setup_nvidia_prime
    fi

    setup_proton_PATH
    setup_WINEPREFIX_proton
    setup_WINEPREFIX_SYMLINK

    if [ -z "${WINE}" ] || [ -z "${WINEARCH}" ]; then
        setup_WINE_and_WINEARCH
    fi

    if [ -n "${SETUP_WEBVIEW2}" ]; then
        setup_webview2
    fi

    if [ -n "${SETUP_WINETRICKS}" ]; then
        setup_winetricks
    fi

}


function error_handler {
    echo "Error occurred on line $(caller)" >&2
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=$1 $0 >&2
}
if (echo "${SHELL}" | grep "bash"); then
    trap 'error_handler $LINENO' ERR
fi


if [ "$(id -u)" -eq 0 ] && [ -z "${__ALLOW_RUN_AS_ROOT}" ]; then
    echo "INFO: Not running (source ${_this} && setup_devcontainer_main) as root:"
    (set -x; id -u)
else
    if [ -n "${__TEST}" ]; then
        echo "INFO: _test_all starting... (__TEST=${__TEST})"
        _test_all
        retcode=$?
        echo "INFO: _test_all done."
        return "${retcode}"
    fi
    if [ -z "${__SKIP_MAIN}" ]; then
        setup_devcontainer_main
    fi
fi