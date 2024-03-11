#!/usr/bin/env bash
set -e

# https://www.reddit.com/r/Ubiquiti/comments/lgwvzc/comment/gmuo5wy/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_buttonj

ssid="JPsGuests"
username="HomeAssistant"
password="NY3-sR_VGZnQUGvMkeHxzXUw*"
baseurl="10.0.100.1"
site=default

cookie=$(mktemp)
curl_cmd="curl --tlsv1 --silent --cookie ${cookie} --cookie-jar ${cookie} --insecure "

unifi_requires() {
    if [ -z "$username" -o -z "$password" -o -z "$baseurl" -o -z "$site" -o -z "$ssid" ] ; then
        echo "Error! please define required env vars before including unifi_sh. E.g. "
        echo ""
        echo "export username=ubnt"
        echo "export password=ubnt"
        echo "export baseurl=https://localhost:8443"
        echo "export site=default"
        echo "export ssid=GuestWifi"
        echo ""
        return
    fi
}

unifi_login() {
    # authenticate against unifi controller
    ${curl_cmd} --data "{\"username\":\"$username\", \"password\":\"$password\"}" $baseurl/api/login > /dev/null
}

unifi_logout() {
    # logout
    ${curl_cmd} $baseurl/logout > /dev/null
}

# shellcheck ignore sc2120
unifi_get_wlanconf() {
    if [ $# -lt 0 ] ; then
        echo "Usage: $0 [id]"
        return
    fi
    id=$1
    ${curl_cmd} $baseurl/proxy/network/api/s/$site/rest/wlanconf/$id | json_pp
}

unifi_set_wlanconf() {
    if [ $# -lt 2 ] ; then
        echo "Usage: $0 id passphrase"
        return
    fi
    id=$1
    psk=$2
    ${curl_cmd} -X PUT -H "Content-Type: application/json" --data "{\"x_passphrase\": \"${psk}\"}" $baseurl/proxy/network/api/s/$site/rest/wlanconf/$id > /dev/null
}

NEWPASS=$(/opt/homebrew/bin/xkcdpass -n4)

unifi_requires

unifi_login

IDNO=$(unifi_get_wlanconf | \
        /usr/local/bin/jq -r ".data|.[]|select(.name==\"${ssid}\")|._id")

unifi_set_wlanconf "${IDNO}" "${NEWPASS}"

unifi_logout
