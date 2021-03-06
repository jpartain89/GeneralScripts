#!/bin/bash -e

# This script checks for and creates if needed the directories for Office 2016 templates for Word, PowerPoint and Excel
# Made by Rich-the-Great

function test_command {
    "$@"
    local status=$?
    /bin/echo -n "Executing '$@'… "
    if [ $status -ne 0 ]; then
        echo "ERROR: $@" >&2
        exit $status
    fi
    echo "OK"
}

if [[ ! -d "/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized" ]]; then
    echo "Necessary support directories for Office 2016 templates not found."
    echo "Creating necessary support directories for Office 2016 templates."

    test_command mkdir -p "/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized"

    # We don't use -R to make sure we don't step on anybody's shoe
    # On a fresh 15.19.1 install, perms are root:wheel 755
    test_command chown root:wheel "/Library/Application Support/Microsoft/Office365"
    test_command chown root:wheel "/Library/Application Support/Microsoft/Office365/User Content.localized"
    test_command chown root:wheel "/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized"
    test_command chmod 755 "/Library/Application Support/Microsoft/Office365"
    test_command chmod 755 "/Library/Application Support/Microsoft/Office365/User Content.localized"
    test_command chmod 755 "/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized"
fi

cat << EOF >> "/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized/office365_MeContact"
#!/bin/bash -e

PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/Cellar"
export PATH

# Variable used to store the file name of this script
fullScriptName="$(basename "$0")"

# Variable used to store the search path used by the dscl command.
dsclSearchPath="/Local/Default"

# Get the username of the person currently running the script.
userName=$(id -un)

echo "$fullScriptName -- Personalizing Office 2016 for $userName"

# Lookup the user's name from the local directory
firstName=$(dscl "${DsclSearchPath}" -read "/Users/${userName}" RealName | tr -d '\n' | awk '{print $2}')

lastName=$(dscl "${DsclSearchPath}" -read "/Users/${userName}" RealName | tr -d '\n' | awk '{print $3}')

# Get the first letter for the initial
firstInitial="${firstname:0:1}"

# Get the first letter for the initial
lastInitial="${lastname:0:1}"

# Concatenate the initials together into one variable.
userInitials="${firstInitial}${lastInitial}"

# Concatenate the full name together into one variable.
userFullName="${firstName} ${lastName}"

# Remove any leading or trailing whitepace
userFullName="$(echo -e "${UserFullName}" | sed -e 's/^[[:space:]]//' -e 's/[[:space:]]$//')"

userInitials="$(echo -e "${UserInitials}" | sed -e 's/^[[:space:]]//' -e 's/[[:space:]]$//')"

defaults write "/Users/${userName}/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Name "$userFullName"

defaults write "/Users/${userName}/Library/Group Containers/UBF8T346G9.Office/MeContact.plist" Initials "$userInitials"

echo "$fullScriptName -- Completed personalizing Office 2016 for $userName"

# Quit the script without errors.
exit 0
EOF

chmod +x "/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized/office365_MeContact"
