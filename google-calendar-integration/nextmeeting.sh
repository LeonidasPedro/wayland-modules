#!/bin/bash

# Google Calendar next meeting for waybar module

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/google-integration.conf"

nextmeeting --waybar --calendar="${GCAL_CALENDAR}"
