#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Creative Commons Zero v1.0 Universal
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.3.0-SNAPSHOT
#
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH

if ! [[ -v scriptsDir ]]; then
	scriptsDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)"
	declare -r scriptsDir
fi

if ! [[ -v projectDir ]]; then
	projectDir="$(realpath "$scriptsDir/../")"
	declare -r projectDir
fi

if ! [[ -v dir_of_github_commons ]]; then
	dir_of_github_commons="$projectDir/src"
	declare -r dir_of_github_commons
fi

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$projectDir/lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$dir_of_tegonal_scripts/releasing/release-files.sh"

function release() {

	function findFilesToRelease() {
		find "$projectDir/src" \
			"$projectDir/.editorconfig" \
			"$projectDir/.shellcheckrc" \
			-not -name "*.sig" \
			"$@"
	}

	# same as in prepare-next-dev-cycle.sh, update there as well
	local -r additionalPattern="(TEGONAL_GITHUB_COMMONS_(?:LATEST_VERSION_)?VERSION=['\"])[^'\"]+(['\"])"

	releaseFiles --project-dir "$projectDir" -p "$additionalPattern" --sign-fn findFilesToRelease "$@"
}

${__SOURCED__:+return}
release "$@"
