# inspired by https://gist.github.com/JonnyWong16/f8139216e2748cb367558070c1448636
# adapted by eric capuano, @eric_capuano@infosec.exchange
# modified to support python3, and supports updating ALL users instead of specifying userIDs manually.
#
# first, add your PLEX_TOKEN and SERVER_ID
# second, add the libraries you want to share/unshare to SHARED_LIBRARY_IDS
# usage: python3 share_unshare_libraries.py share/unshare

import requests
from xml.dom import minidom
import sys

## EDIT THESE SETTINGS ###
# get a plex token: https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/
PLEX_TOKEN = "krcW45N5vsxtJ2xX6qK3"

# get your server ID: https://www.reddit.com/r/PleX/comments/t6ylce/server_id/
# or https://www.plexopedia.com/plex-media-server/api/server/identity/
# Example: https://i.imgur.com/EjaMTUk.png
SERVER_ID = "2835372f5251eafa1e8e6a078728710d553f8da6"

# Specify the library IDs you want to share with all users
# Get the Library IDs from
# https://plex.tv/api/servers/SERVER_ID/shared_servers
# Example: https://i.imgur.com/yt26Uni.png
# Enter the Library IDs in this format below:
#    [LibraryID1, LibraryID2]
SHARED_LIBRARY_IDS = [123456, 234567]  # Replace with your actual library IDs

## DO NOT EDIT BELOW ##

def fetch_user_ids():
    headers = {"X-Plex-Token": PLEX_TOKEN, "Accept": "application/xml"}
    url = "https://plex.tv/api/users"
    r = requests.get(url, headers=headers)

    if r.status_code != 200:
        print("Error fetching users: {}".format(r.content))
        return []

    # Parse XML response
    user_ids = []
    try:
        dom = minidom.parseString(r.content)
        for user in dom.getElementsByTagName('User'):
            user_ids.append(int(user.getAttribute('id')))
    except Exception as e:
        print("Error parsing XML: {}".format(e))
        return []

    return user_ids

def share():
    user_ids = fetch_user_ids()
    if not user_ids:
        print("No user IDs found or error fetching user IDs.")
        return

    headers = {"X-Plex-Token": PLEX_TOKEN, "Accept": "application/xml"}
    shared_servers_url = "https://plex.tv/api/servers/" + SERVER_ID + "/shared_servers"
    r = requests.get(shared_servers_url, headers=headers)

    if r.status_code != 200:
        print("Error fetching shared servers: {}".format(r.content))
        return

    existing_shares = {}
    try:
        response_xml = minidom.parseString(r.content)
        for shared_server in response_xml.getElementsByTagName("SharedServer"):
            user_id = int(shared_server.getAttribute("userID"))
            shared_server_id = int(shared_server.getAttribute("id"))
            libraries = [int(lib.getAttribute("id")) for lib in shared_server.getElementsByTagName("Section")]
            existing_shares[user_id] = (shared_server_id, libraries)
    except Exception as e:
        print("Error parsing XML: {}".format(e))
        return

    for user_id in user_ids:
        if user_id in existing_shares:
            shared_server_id, existing_lib_ids = existing_shares[user_id]
            updated_lib_ids = list(set(existing_lib_ids + SHARED_LIBRARY_IDS))
            payload = {"server_id": SERVER_ID, "shared_server": {"library_section_ids": updated_lib_ids, "invited_id": user_id}}
            update_url = shared_servers_url + '/' + str(shared_server_id)
            r = requests.put(update_url, headers=headers, json=payload)
        else:
            payload = {"server_id": SERVER_ID, "shared_server": {"library_section_ids": SHARED_LIBRARY_IDS, "invited_id": user_id}}
            r = requests.post(shared_servers_url, headers=headers, json=payload)

        if r.status_code not in [200, 201]:
            print("Error sharing libraries with user {}: {}".format(user_id, r.content))
        else:
            print("Shared libraries with user {}".format(user_id))

    return

def unshare():
    headers = {"X-Plex-Token": PLEX_TOKEN, "Accept": "application/xml"}
    shared_servers_url = "https://plex.tv/api/servers/" + SERVER_ID + "/shared_servers"
    r = requests.get(shared_servers_url, headers=headers)

    if r.status_code != 200:
        print("Error fetching shared servers: {}".format(r.content))
        return

    existing_shares = {}
    try:
        response_xml = minidom.parseString(r.content)
        for shared_server in response_xml.getElementsByTagName("SharedServer"):
            user_id = int(shared_server.getAttribute("userID"))
            shared_server_id = int(shared_server.getAttribute("id"))
            existing_shares[user_id] = shared_server_id
    except Exception as e:
        print("Error parsing XML: {}".format(e))
        return

    for user_id, shared_server_id in existing_shares.items():
        unshare_url = shared_servers_url + '/' + str(shared_server_id)
        r = requests.delete(unshare_url, headers=headers)

        if r.status_code == 200:
            print("Unshared libraries with user {}".format(user_id))
        else:
            print("Error unsharing libraries with user {}: {}".format(user_id, r.content))

    return

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print('You must provide "share" or "unshare" as an argument')
    elif sys.argv[1] == "share":
        share()
    elif sys.argv[1] == "unshare":
        unshare()

