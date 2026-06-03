# MIT License
# Copyright (c) 2020 Sukka

# https://github.com/SukkaW/zsh-osx-autoproxy

proxy_on() {
    emulate -L zsh -o extended_glob
    # export https_proxy=http://127.0.0.1:6152
    # export http_proxy=http://127.0.0.1:6152
    # export all_proxy=socks5://127.0.0.1:6153

    # Cache the output of scutil --proxy
    local scutil_output=$(scutil --proxy)
    local -A info=(${=${(M)${(f)scutil_output}:#[A-Za-z ]# : [^ ]#}/:})

    local proxy_enabled=0

    if (( $info[HTTPEnable] )); then
        export http_proxy=http://$info[HTTPProxy]:$info[HTTPPort]
        export HTTP_PROXY=http://$info[HTTPProxy]:$info[HTTPPort]
        proxy_enabled=1
    fi
    if (( $info[HTTPSEnable] )); then
        export https_proxy=http://$info[HTTPSProxy]:$info[HTTPSPort]
        export HTTPS_PROXY=http://$info[HTTPSProxy]:$info[HTTPSPort]
        proxy_enabled=1
    fi
    if (( $info[FTPSEnable] )); then
        export ftp_proxy=http://$info[SOCKSProxy]:$info[SOCKSPort]
        export FTP_PROXY=http://$info[SOCKSProxy]:$info[SOCKSPort]
        proxy_enabled=1
    fi
    if (( $info[SOCKSEnable] )); then
        export all_proxy=socks5://$info[SOCKSProxy]:$info[SOCKSPort]
        export ALL_PROXY=socks5://$info[SOCKSProxy]:$info[SOCKSPort]
        proxy_enabled=1
    elif (( $info[HTTPEnable] )); then
        export all_proxy=http://$info[HTTPProxy]:$info[HTTPPort]
        export ALL_PROXY=http://$info[HTTPProxy]:$info[HTTPPort]
        proxy_enabled=1
    fi

    if (( $proxy_enabled )); then
        local -A raw_scutil_noproxy=(${=${(M)${(f)scutil_output}:#  [0-9 ]# : [^ ]#}/:})
        local _noproxy=${(j:, :)${(o)raw_scutil_noproxy}}

        # Strip IPv6 entries (any entry with 2+ colons, e.g. ::1/128, fc00::/7).
        # httpx and most Python HTTP libs don't support IPv6 in NO_PROXY and crash
        # trying to parse them as URLs. IPv4 CIDRs are kept (they don't crash parsers).
        local -a _noproxy_normalized=()
        for _entry in ${(s:, :)_noproxy}; do
            [[ $_entry == *:*:* ]] && continue
            _noproxy_normalized+=("$_entry")
        done
        _noproxy="${(j:, :)_noproxy_normalized}"

        export NO_PROXY=$_noproxy
        export no_proxy=$_noproxy
    fi
}

if (( $OSTYPE[(I)darwin] )); then
    proxy_on
fi

proxy_off() {
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
    unset all_proxy
    unset ALL_PROXY
    unset ftp_proxy
    unset FTP_PROXY
    unset NO_PROXY
    unset no_proxy
}
