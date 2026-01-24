#!/bin/bash

set -euo pipefail


# MOCK Functions for testing
mock_test_mode=0
if [ "${mock_test_mode:-0}" -eq 1 ]; then
    sudo() {
        printf '%s\n' "[MOCK] sudo $*"
    }
    flatpak() {
        printf '%s\n' "[MOCK] flatpak $*"
    }
fi

# Variables

menu_options=(
    'sudo nala update && sudo nala upgrade'
    'flatpak update'
    'Update all (above commands)'
    'Cancel'
)

# Functions

## Nala semantics
nala_upgrade() {
    if [ "$use_yes" -eq 1 ]; then
        sudo nala upgrade -y
    else
        sudo nala upgrade
    fi
}
nala_failed() {
    echo "Nala failed, continuing to next step."
}

## Flatpak semantics
flatpak_update() {
    if [ "$use_yes" -eq 1 ]; then
        flatpak update -y
    else
        flatpak update
    fi
}

## [Y/n]
#  - Move the '' to the no section to change to default no.
yes_no () {
    while true; do
        echo "Would you like to pass -y to the commands? [Y/n]"
        read -r response

        case "$response" in
            n|N|[nN]o|[nN]O|[nN][oO])
                return 1
                ;;
            ''|[yY]|[yY]es|[yY][eE][sS])
                return 0
                ;;
            *)
                echo "Invalid response"
                ;;
        esac
    done
}

## Updater
update_func () {
    local option="$1"
    case "$option" in
        "sudo nala update && sudo nala upgrade")
            sudo nala update || nala_failed
            nala_upgrade || nala_failed
            ;;
        "flatpak update")
            flatpak_update
            ;;
        "Update all (above commands)")
                sudo nala update || nala_failed
                nala_upgrade || nala_failed
                flatpak_update
            ;;
        "Cancel")
            echo "Canceling."
            exit
            ;;
        *)
            echo "Invalid choice, select a number between 1 and 4."
            ;;
    esac
}

## Menus
select_options () {
    PS3="Select update commands: "
    select opt in "${menu_options[@]}"; do
        if [ "$opt" == 'Cancel' ]; then
            echo "Cancelled."
            exit 0
        fi

        if [ -n "$opt" ]; then
            local option="$opt"
            break
        else
            echo "Please select a choice between 1 and ${#menu_options[@]}"
        fi
    done

    if yes_no; then
        use_yes=1
    else
        use_yes=0
    fi

    update_func "$option"
}

# MAIN

select_options

# Check if reboot required
if [ -f /var/run/reboot-required ]; then
    echo -e "\n\033[1;31m[!] A system restart is required to finish updates.\033[0m"
    cat /var/run/reboot-required.pkgs
fi