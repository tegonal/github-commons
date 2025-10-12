#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v4.0.0
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH
TEGONAL_GITHUB_COMMONS_VERSION="v4.0.0"

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

	# shellcheck disable=SC2034   # they seem unused but are necessary in order that parseArguments doesn't create global readonly vars
	local version projectsRootDir additionalPattern beforePrFn
	# shellcheck disable=SC2034   # is passed by name to parseArguments
	local -ra params=(
		version "$versionParamPattern" 'the version for which we prepare the dev cycle'
		projectsRootDir "$projectsRootDirParamPattern" "$projectsRootDirParamDocu"
		additionalPattern "$additionalPatternParamPattern" "is ignored as additional pattern is specified internally, still here as release-files uses this argument"
		beforePrFn "$beforePrFnParamPattern" "$beforePrFnParamDocu"
	)
	parseArguments params "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@"
	# we don't check if all args are set (and neither set default values for most) as we currently don't use
	# any param in here (except for projectsRootDir) but just delegate to prepareFilesNextDevCycle.
	if ! [[ -v projectsRootDir ]]; then projectsRootDir=$(realpath ".") || die "could not determine realpath of ."; fi

	function prepare_next_afterVersionHook() {
		local version projectsRootDir additionalPattern
		parseArguments afterVersionHookParams "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@"

		updateVersionInNonShFiles -v "$version-SNAPSHOT" --project-dir "$projectsRootDir"
	}

	# similar as in release.sh, you might need to update it there as well if you change something here
	local -r additionalPattern="(TEGONAL_GITHUB_COMMONS_VERSION=['\"])[^'\"]+(['\"])"

	prepareFilesNextDevCycle \
		--project-dir "$projectsRootDir" \
		"$@" \
		--pattern "$additionalPattern" \
		--after-version-update-hook prepare_next_afterVersionHook
}

${__SOURCED__:+return}
prepareNextDevCycle "$@"
