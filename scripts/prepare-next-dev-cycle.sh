#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v2.2.0-SNAPSHOT
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH

if ! [[ -v scriptsDir ]]; then
	scriptsDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)"
	readonly scriptsDir
fi

if ! [[ -v projectDir ]]; then
	projectDir="$(realpath "$scriptsDir/../")"
	readonly projectDir
fi

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$projectDir/lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$dir_of_tegonal_scripts/releasing/prepare-files-next-dev-cycle.sh"

function prepareNextDevCycle() {
	local -r additionalPattern="(TEGONAL_GITHUB_COMMONS_VERSION=['\"])[^'\"]+(['\"])"

	prepareFilesNextDevCycle "$@" --project-dir "$projectDir" -p "$additionalPattern"
}

${__SOURCED__:+return}
prepareNextDevCycle "$@"
