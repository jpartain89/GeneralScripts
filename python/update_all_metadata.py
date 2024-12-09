#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Description:  Updates all metadata in the Tautulli database after moving Plex libraries.
# Author:       /u/SwiftPanda16
# Requires:     plexapi, requests

from plexapi.server import PlexServer
import requests

### EDIT SETTINGS ###

## Install the required modules listed above with:
##    python -m pip install plexapi
##    python -m pip install requests

TAUTULLI_URL = 'http://localhost:8181'
TAUTULLI_APIKEY = 'xxxxxxxxxx'
PLEX_URL = 'http://localhost:32400'
PLEX_TOKEN = 'xxxxxxxxxx'

FALLBACK_MATCH_TITLE_YEAR = True  # True or False, fallback to matching by title and year if matching by ID fails
FALLBACK_MATCH_TITLE = True       # True or False, fallback to matching by title ONLY if matching by title and year fails
DRY_RUN = TRUE                    # True to dry run without making changes to the Tautulli database, False to make changes



## CODE BELOW ##

def get_id_from_guid(guid):
    id = None
    if 'imdb://' in guid:
        id = 'imdb://' + guid.split('imdb://')[1].split('?')[0]
    elif 'themoviedb://' in guid:
        id = 'tmdb://' + guid.split('themoviedb://')[1].split('?')[0]
    elif 'thetvdb://' in guid:
        id = 'tvdb://' + guid.split('thetvdb://')[1].split('?')[0].split('/')[0]
    elif 'plex://' in guid:
        id = 'plex://' + guid.split('plex://')[1]
    elif 'tmdb://' in guid or 'tvdb://' in guid or 'mbid://' in guid:
        id = guid
    return id


def main():
    session = requests.Session()

    new_key_map = {}
    old_key_map = {}

    # Check for DRY_RUN. Backup Tautulli database if needed.
    if DRY_RUN:
        print("Dry run enabled. No changes will be made to the Tautulli database.")
    else:
        print("Not dry run. Creating a backup of the Tautulli database.")
        params = {
            'cmd': 'backup_db',
            'apikey': TAUTULLI_APIKEY,
        }
        session.post(TAUTULLI_URL.rstrip('/') + '/api/v2', params=params)

    # Get all old items from the Tautulli database (using raw SQL)
    print("Retrieving all history items from the Tautulli database...")

    recordsFiltered = None
    count = 0
    start = 0
    while recordsFiltered is None or count < recordsFiltered:
        params = {
            'cmd': 'get_history',
            'apikey': TAUTULLI_APIKEY,
            'grouping': 0,
            'include_activity': 0,
            'media_type': 'movie,episode,track',
            'order_column': 'date',
            'order_dir': 'desc',
            'start': start,
            'length': 1000
        }
        r = session.get(TAUTULLI_URL.rstrip('/') + '/api/v2', params=params).json()

        if r['response']['result'] == 'error':
            print("Error retrieving Tautulli history: {}".format(r['response']['message']))
            print("Exiting script...")
            return
        
        else:
            if recordsFiltered is None:
                recordsFiltered = r['response']['data']['recordsFiltered']

            for row in r['response']['data']['data']:
                count += 1

                if row['media_type'] not in ('movie', 'episode'):
                    continue

                id = get_id_from_guid(row['guid'])
                if id:
                    key = row['grandparent_rating_key'] or row['rating_key']
                    media_type = 'show' if row['media_type'] == 'episode' else row['media_type']
                    title = row['grandparent_title'] or row['title']
                    year = str(row['year'])

                    old_key_map[id] = (key, media_type, title, year)
                else:
                    title = row['grandparent_title'] or row['title']
                    print("\tUnsupported guid for '{title}' in the Tautulli database [Guid: {guid}]. Skipping...".format(title=title, guid=row['guid']))

        start += 1000

    # Get all new items from the Plex server
    print("Retrieving all library items from the Plex server...")

    plex = PlexServer(PLEX_URL, PLEX_TOKEN)

    for library in plex.library.sections():
        if library.type not in ('movie', 'show') or library.agent == 'com.plexapp.agents.none':
            print("\tSkipping library: {title}".format(title=library.title))
            continue

        print("\tScanning library: {title}".format(title=library.title))
        for item in library.all():
            id = get_id_from_guid(item.guid)
            if id:
                new_key_map[id] = (item.ratingKey, item.type, item.title, str(item.year))
            else:
                print("\t\tUnsupported guid for '{title}' in the Plex library [Guid: {guid}]. Skipping...".format(title=item.title, guid=item.guid))

            for guid in item.guids:  # Also parse <Guid> tags for new Plex agents
                id = get_id_from_guid(guid.id)
                if id:
                    new_key_map[id] = (item.ratingKey, item.type, item.title, str(item.year))

    new_title_year_map = {(title, year): (id, key, media_type) for id, (key, media_type, title, year) in new_key_map.items()}
    new_title_map = {title: (id, key, media_type, year) for id, (key, media_type, title, year) in new_key_map.items()}

    # Update metadata in the Tautulli database
    print("{}Matching Tautulli items with Plex items...".format("(DRY RUN) " if DRY_RUN else ""))
    if FALLBACK_MATCH_TITLE_YEAR:
        print("\tUsing fallback to match by title and year.")
    if FALLBACK_MATCH_TITLE:
        print("\tUsing fallback to match by title ONLY.")
    if not FALLBACK_MATCH_TITLE_YEAR and not FALLBACK_MATCH_TITLE:
        print("\tNot using any fallback to title or year.")

    updated = []
    no_mapping = set()

    for id, (old_rating_key, old_type, title, year) in old_key_map.items():
        new_rating_key, new_type, _, _ = new_key_map.get(id, (None, None, None, None))
        new_year = None
        warning_year = False

        if not new_rating_key and FALLBACK_MATCH_TITLE_YEAR:
            _, new_rating_key, new_type = new_title_year_map.get((title, year), (None, None, None))
            if not new_rating_key and FALLBACK_MATCH_TITLE:
                _, new_rating_key, new_type, new_year = new_title_map.get(title, (None, None, None, None))
            
        if new_rating_key:
            if new_rating_key != old_rating_key and new_type == old_type:
                if new_year is not None and new_year != year:
                    warning_year = True
                updated.append((title, year, old_rating_key, new_rating_key, new_type, new_year, warning_year))
        else:
            no_mapping.add((title, year, old_rating_key))

    if updated:
        if not DRY_RUN:
            url = TAUTULLI_URL.rstrip('/') + '/api/v2'
            for title, year, old_rating_key, new_rating_key, new_type, new_year, warning_year in updated:
                params = {
                    'cmd': 'update_metadata_details',
                    'apikey': TAUTULLI_APIKEY,
                    'old_rating_key': old_rating_key,
                    'new_rating_key': new_rating_key,
                    'media_type': new_type
                }
                session.post(url, params=params)

        print("{}Updated metadata for {} items:".format("(DRY RUN) " if DRY_RUN else "", len(updated)))
        for title, year, old_rating_key, new_rating_key, new_type, new_year, warning_year in updated:
            if warning_year:
                print("\t{title} ({year} --> {new_year}) [Rating Key: {old} --> {new}]".format(
                      title=title, year=year, new_year=new_year, old=old_rating_key, new=new_rating_key))
            else:
                print("\t{title} ({year}) [Rating Key: {old} --> {new}]".format(
                      title=title, year=year, old=old_rating_key, new=new_rating_key))

    if no_mapping:
        print("{}No match found for {} Tautulli items on the Plex server:".format("(DRY RUN) " if DRY_RUN else "", len(no_mapping)))
        for title, year, old_rating_key in no_mapping:
            print("\t{title} ({year}) [Rating Key: {old}]".format(
                  title=title, year=year, old=old_rating_key))

    # Clear all recently added items in the Tautulli database
    print("{}Clearing all recently added items in the Tautulli database...".format("(DRY RUN) " if DRY_RUN else ""))
    
    if not DRY_RUN:
        params = {
            'cmd': 'delete_recently_added',
            'apikey': TAUTULLI_APIKEY
        }
        r = session.get(TAUTULLI_URL.rstrip('/') + '/api/v2', params=params).json()

        if r['response']['result'] == 'error':
            print("Error clearing the Tautulli recently added database table: {}".format(r['response']['message']))
            print("Exiting script...")
            return

    print("Cleared all items from the Tautulli recently added database table.")


if __name__ == "__main__":
    main()

    print("Done.")
