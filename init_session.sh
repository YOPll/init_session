#!/bin/bash

# Ensure USER variabe is set
[ -z "${USER}" ] && export USER=`whoami`

################################################################################

# Colors
blue=$'\033[0;34m'
cyan=$'\033[1;96m'
red=$'\033[0;91m'
bold=$'\033[1;31m'
reset=$'\033[0;39m'

# Config
scriptdir="$( dirname -- "$BASH_SOURCE"; )";
toolbox_path="$scriptdir"                            #=> Script Path
init_docker=true                                     #=> Init Docker for Mac? See 
init_docker_path="$scriptdir/init_docker.sh"         #=> Location of init_docker.sh file. See 
install_apps=true                                    #=> Install desired apps if they are missing?
start_apps=true 									 #=> Start apps?
if [[ -f "$HOME/goinfre/.brew/bin/brew" ]]
then
	echo "Brew is installed in goinfre"
else
	install_brew=true
	update_brew=true
	upgrade_brew_formulas=true
fi

clean_disk=true                                      #=> Clean disk (deletes ~/Library/Caches, does a brew cleanup, etc)?
open_system_preferences=true                         #=> Open System Preferences at the end? You could need it to edit your keyboard/screen settings, etc.
send_notification=true                               #=> Send a notification when job is done?
dark_mode=true                                       #=> Activate dark mode

# List your desired apps below, used by $install_apps and $start_apps.

declare -a desired_apps=(
	"Discord"
	"Docker"
	"Spotify"
	"Todoist"
	"iTerm"
)

# Check missing apps and open Managed Software Center (MSC) if needed
declare -a apps_to_install=()
if [ "$install_apps" = true ]; then
	for desired_app in "${desired_apps[@]}"; do
		if [ ! -d "/Applications/$desired_app.app" ] && [ ! -d "~/Applications/$desired_app.app" ]; then
			apps_to_install+=( "$desired_app" )
		fi
	done
	if [ ${#apps_to_install[@]} -eq 0 ]; then
		echo -e "${blue}All your apps are already installed! Have a good code session (unless you are a JavaScript guy).${reset}"
	else
		open -a "Managed Software Center"
		echo -e "${blue}Some of your apps are missing:${reset}"
		for app_to_install in "${apps_to_install[@]}"; do
			echo -e "${blue}- ${cyan}${app_to_install}${reset}"
		done
		echo -e "${blue}------------------${reset}"
		read -p "${blue}Please press ${cyan}ENTER${blue}/${cyan}RETURN${blue} when you have installed all your desired apps.${reset}"
	fi
fi

# Open System Preferences
if [ "$open_system_preferences" = true ]; then
	echo -e "${blue}Opening ${cyan}System Preferences${blue}.${reset}"
	osascript -e 'tell application "System Preferences" to activate'
fi

# Activate dark mode
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# Prepare Docker for Mac (configuring it to not fill your poor 5Gb disk space)
$init_docker_path

# Start apps
if [ "$start_apps" = true ]; then
	for app in "${desired_apps[@]}"; do
		pgrep -q "$app"
		if [ $? -ne 0 ]; then
			echo -e "${blue}Starting ${cyan}${app}${reset}"
			open -g -a "$app"
		fi
	done
fi

# Install Homebrew
if [ "$install_brew" = true ]; then
	printf "\n\033[33m installing Brew .... \033[0m"
	sh -c './scripts/spin.bash 2>/dev/null &'
	rm -rf brew* &>/dev/null
	curl -L https://github.com/Homebrew/brew/archive/1.9.0.tar.gz >brew1.9.0.tar.gz 2>/dev/null
	tar -xvzf brew1.9.0.tar.gz &>/dev/null
	rm -rf brew1.9.0.tar.gz &>/dev/null
	mv brew-1.9.0 .brew &>/dev/null
	rm -rf ~/goinfre/.brew &>/dev/null
	cp -Rf .brew ~/goinfre &>/dev/null
	rm -rf ./.brew &>/dev/null


	export PATH=$HOME/goinfre/.brew/bin:$PATH

	# update and upgrade brew
	brew update &>/dev/null
	brew upgrade &>/dev/null

	# downgrade brew to 3.2.17 which can install valgrind
	cd ~/goinfre/.brew &>/dev/null && git fetch --tags &>/dev/null && git checkout -f 3.2.17 &>/dev/null && (cd - &>/dev/null || true)

	# prevent brew from updating itself
	export HOMEBREW_NO_AUTO_UPDATE=1

	if ls ~/goinfre/.brew &>/dev/null; then
		pkill -f spin &>/dev/null
		brew update &>/dev/null
		brew update &>/dev/null
		echo -e "\b\033[32m OK ✅\033[0m"
	else
		pkill -f spin &>/dev/null
		echo -e "\b\033[31m KO ❌\033[0m"
		exit 1

fi

# Upgrade Homebrew formulas
if [ "$upgrade_brew_formulas" = true ]; then
	echo -e "${blue}Updgrading Homebrew formulas.${reset}"
	brew upgrade ;:
fi

# Clean disk
if [ "$clean_disk" = true ]; then
	echo -e "${blue}Cleaning up disk.${reset}"
	rm -rf ~/.cache ~/Library/Caches ;:
	brew cleanup ;:
fi


# Open System Preferences
if [ "$open_system_preferences" = true ]; then
	echo -e "${blue}Opening ${cyan}System Preferences${blue}.${reset}"
	osascript -e 'tell application "System Preferences" to activate'
fi

# Open System Preferences
elif [ "$send_notification" = true ]; then
	osascript -e 'display notification "Your session is ready !" with title "YOPIIIIIIIIIIIII"'
fi;
