#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v2.3.1
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH
TEGONAL_GITHUB_COMMONS_VERSION="v2.3.1"

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
sourceOnce "$scriptsDir/before-pr.sh"
sourceOnce "$scriptsDir/update-version-in-non-sh-files.sh"

function prepareNextDevCycle() {
	source "$dir_of_tegonal_scripts/releasing/common-constants.source.sh" || die "could not source common-constants.source.sh"

	function prepare_next_afterVersionHook() {
		local version projectsRootDir additionalPattern
		parseArguments afterVersionHookParams "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@"

		updateVersionInNonShFiles -v "$version-SNAPSHOT" --project-dir "$projectsRootDir"
	}

	# similar as in release.sh, you might need to update it there as well if you change something here
	local -r additionalPattern="(TEGONAL_GITHUB_COMMONS_VERSION=['\"])[^'\"]+(['\"])"

	prepareFilesNextDevCycle \
		--project-dir "$projectDir" \
		"$@" \
		--pattern "$additionalPattern" \
		--after-version-update-hook prepare_next_afterVersionHook
}

${__SOURCED__:+return}
prepareNextDevCycle "$@"
