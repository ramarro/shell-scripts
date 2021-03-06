#!/usr/bin/env bash

# ##################################################
# My Generic BASH script template
#
version="1.0.0"               # Sets version variable for this script
#
scriptTemplateVersion="1.0.1" # Version of scriptTemplate.sh
#                               that this script is based on
#
# This script installs Homebrew Casks - allowing for command line
# installation of native Mac Applications.  Once Homebrew Casks is installed,
# this script then installs a number of applications.
#
# For logging levels use the following functions:
#   - header:   Prints a script header
#   - input:    Ask for user input
#   - success:  Print script success
#   - info:     Print information to the user
#   - notice:   Notify the user of something
#   - warning:  Warn the user of something
#   - error:    Print a non-fatal error
#   - die:      A fatal error.  Will exit the script
#   - debug:    Debug information
#   - verbose:  Debug info only printed when 'verbose' flag is set to 'true'.
#
# HISTORY:
#
# * 2015-02-07 - v1.0.0  - First Creation
#
# ##################################################

# Source Scripting Utilities
# -----------------------------------
# If these can't be found, update the path to the file
# -----------------------------------
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "${SCRIPTDIR}/../lib/utils.sh" ]; then
  source "${SCRIPTDIR}/../lib/utils.sh"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting."
  exit 1
fi

# trapCleanup Function
# -----------------------------------
# Any actions that should be taken if the script is prematurely
# exited.  Always call this function at the top of your script.
# -----------------------------------
function trapCleanup() {
  echo ""
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  die "Exit trapped."  # Edit this if you like.
}

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=0
printLog=0
verbose=0
force=0
strict=0


# Set Local Variables
# -----------------------------------
# A set of variables used by many scripts
# -----------------------------------

# Set Script name and location variables
scriptName=`basename ${0}`  # Full name
scriptBasename="$(basename ${scriptName} .sh)" # Strips '.sh' from name
scriptPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set time stamp
now=$(date +"%m-%d-%Y %r")
# Set hostname
thisHost=$(hostname)

# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
  tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
  (umask 077 && mkdir "${tmpDir}") || {
    die "Could not create temporary directory! Exiting."
  }

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${scriptBasename}.log
# Save to standard user log location use: $HOME/Library/Logs/${scriptBasename}.log
# -----------------------------------
logFile="$HOME/Library/Logs/${scriptBasename}.log"


function mainScript() {
############## Begin Script Here ###################
header "Beginning ${scriptName}"


# Set Variables
LISTINSTALLED="brew cask list"
INSTALLCOMMAND="brew cask install --appdir=/Applications"

RECIPES=(
    alfred
    arq
    authy-bluetooth
    bartender
    betterzipql
    capo
    carbon-copy-cloner
    cheatsheet
    codekit
    controlplane
    default-folder-x
    dropbox
    evernote
    fantastical
    firefox
    flux
    fluid
    github
    google-chrome
    hazel
    houdahgeo
    iterm2
    imagealpha
    imageoptim
    istat-menus
    java
    joinme
    kaleidoscope
    launchbar
    licecap
    mamp
    marked
    mailplane
    moom
    nvalt
    omnifocus
    omnifocus-clip-o-tron
    1password
    plex-home-theater
    qlcolorcode
    qlmarkdown
    qlprettypatch
    qlstephen
    quicklook-csv
    quicklook-json
    skitch
    spillo
    sublime-text3
    suspicious-package
    textexpander
    tower
    vlc
    vyprvpn
    webpquicklook
    xld
)

# Run Functions

hasHomebrew
hasCasks
brewMaintenance
doInstall
brewCleanup


header "Completed ${scriptName}"
############## End Script Here ###################
}

############## Begin Options and Usage ###################


# Print usage
usage() {
  echo -n "${scriptName} [OPTION]... [FILE]...

This script installs Homebrew Casks - allowing for command line
installation of native Mac Applications.  Once Homebrew Casks is installed,
this script then installs a number of applications.

 Options:
  -f, --force       Skip all user interaction.  Implied 'Yes' to all actions
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safeExit ;;
    --version) echo "$(basename $0) $version"; safeExit ;;
    -u|--username) shift; username=$1 ;;
    -p|--password) shift; password=$1 ;;
    -v|--verbose) verbose=1 ;;
    -l|--log) printLog=1 ;;
    -q|--quiet) quiet=1 ;;
    -s|--strict) strict=1;;
    -f|--force) force=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done


############## End Options and Usage ###################




# ############# ############# #############
# ##       TIME TO RUN THE SCRIPT        ##
# ##                                     ##
# ## You shouldn't need to edit anything ##
# ## beneath this line                   ##
# ##                                     ##
# ############# ############# #############

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Exit on error. Append ||true if you expect an error.
set -o errexit

# Exit on empty variable
if [ "${strict}" = "1" ]; then
  set -o nounset
fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`
set -o pipefail


mainScript # Run your script

safeExit # Exit cleanly