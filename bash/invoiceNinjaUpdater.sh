#!/bin/bash -ue
#Invoice Ninja Self-Hosted Update
#PLEASE SEE THE README AT https://pastebin.com/nwcSH0TH

#SET INVOICE NINJA INSTALL AND STORAGE PATHS
#--------------------------------------------------------
sudo updatedb
ninja_home="$(locate -b '\composer.json' | xargs grep -l "invoiceninja/invoiceninja" | xargs -n 1 dirname)"
ninja_storage="$ninja_home/storage"


#GET INSTALLED AND CURRENT VERSION NUMBERS
#--------------------------------------------------------
versiontxt="$ninja_storage/version.txt"
ninja_installed="$(cat "$versiontxt")"
ninja_current="$((wget -T 15 -qO- https://invoiceninja.org/index.php) | (grep -oP 'Download Version \K[0-9]+\.[0-9]+(\.[0-9]+)'))"


#SEE IF AN UPDATE IS REQUIRED
#--------------------------------------------------------
update_required="no"
set -f
array_ninja_installed=(${ninja_installed//./ })
array_ninja_current=(${ninja_current//./ })

if (( ${#array_ninja_installed[@]} == "2" ))
then
    array_ninja_installed+=("0")
fi

for ((i=0; i<${#array_ninja_installed[@]}; i++))
do
    if (( ${array_ninja_installed[$i]} < ${array_ninja_current[$i]} ))
    then
    update_required="yes"
    fi
done


#MAIN UPDATE SECTION
#--------------------------------------------------------
case $update_required in
    no)
	printf '%s - Invoice Ninja v%s is installed and is current. No update required.\n' "$(date)" "$ninja_installed"
	;;
    yes)
	printf '\n%s - Updating Invoice Ninja from v%s to v%s.\n\n' "$(date)" "$ninja_installed" "$ninja_current"

	#Set remaining variables
	tempdir="/usr/local/download/InvoiceNinja"
	ninja_temp="$tempdir/ninja"
	ninja_file="ninja-v$ninja_current.zip"
	ninja_url="https://download.invoiceninja.com/$ninja_file"
	ninja_zip="$tempdir/$ninja_file"
	ninja_env="$ninja_home/.env"
	update_url="$(grep -oP '(?<=APP_URL=).*' "$ninja_env")""/update"
	storage_owner="$(stat -c "%U" "$ninja_storage")"
	storage_group="$(stat -c "%G" "$ninja_storage")"

        printf 'Deleting file "%s" (if it exists)...\n\n' "$ninja_home/bootstrap/cache/compiled.php"
        set +e
        sudo rm "$ninja_home/bootstrap/cache/compiled.php"
        set -e

	printf 'Downloading Invoice Ninja v%s archive "%s" ...\n\n' "$ninja_current" "$ninja_url"
	wget -P "$tempdir/" "$ninja_url"

	printf 'Extracting to temporary folder "%s" ...\n\n' "$tempdir"
	unzip -q "$ninja_zip" -d "$tempdir/"

	printf 'Syncing to install folder "%s" ...\n' "$ninja_home"
	sudo rsync -tr --stats "$ninja_temp/" "$ninja_home/"

	printf '\nResetting permissions for "%s" ...\n\n' "$ninja_storage"
	sudo chown -R "$storage_owner":"$storage_group" "$ninja_storage/"
	sudo chmod -R 775 "$ninja_storage/"

	printf 'Removing downloaded ZIP file "%s" ...\n\nRemoving temporary folder "%s" ...\n\n' "$ninja_zip" "$tempdir"
	rm -rf "$tempdir/"

	printf 'Running update migration commands (%s)...\n\n' "$update_url"
	case $(grep -c "UPDATE_SECRET" "$ninja_env") in
	0)
	    wget -q --spider "$update_url"
	    ;;
	1)
	    update_key="$(grep -oP '(?<=UPDATE_SECRET=).*' "$ninja_env")"
	    wget -q --spider "$update_url"?secret="$update_key"
	    ;;
	esac

	printf '%s - Invoice Ninja successfully updated to v%s!\n\n' "$(date)" "$ninja_current"
	;;
esac
