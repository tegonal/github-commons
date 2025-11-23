#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v5.1.0-SNAPSHOT
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH

if ! (($# == 1)); then
	echo >&2 "no commands provided via first argument or more than one argument provided"
	exit 1
fi

# e.g. gitlab passes `sh -c ...`, in this case we just exec bash and the command will then be executed there
if [[ "$1" =~ ^sh|bash ]]; then
	/usr/bin/env bash
else
	eval "$1"
fi
