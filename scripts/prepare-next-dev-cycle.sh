#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v6.1.0-SNAPSHOT
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH
TEGONAL_GITHUB_COMMONS_VERSION="v6.1.0-SNAPSHOT"

if ! [[ -v scriptsDir ]]; then
	scriptsDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)"
	readonly scriptsDir
fi
source "$scriptsDir/dirs.source.sh"

sourceOnce "$dir_of_tegonal_scripts/releasing/prepare-files-next-dev-cycle.sh"
sourceOnce "$scriptsDir/before-pr.sh"
sourceOnce "$scriptsDir/update-version-in-non-sh-files.sh"

function prepareNextDevCycle() {
	source "$dir_of_tegonal_scripts/releasing/params/prepare-files-next-dev-cycle.params.source.sh" || traceAndDie "could not source prepare-files-next-dev-cycle.params.source.sh"
	source "$dir_of_tegonal_scripts/releasing/params/prepare-files-next-dev-cycle.params-definition.source.sh" || traceAndDie "could not source prepare-files-next-dev-cycle.params-definition.source.sh"
	parseArguments prepareFilesNextDevCycleParams "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@" || return $?
	source "$dir_of_tegonal_scripts/releasing/params/prepare-files-next-dev-cycle.default-args.source.sh" || die "could not source prepare-files-next-dev-cycle.default-args.source.sh"
	exitIfNotAllArgumentsSet prepareFilesNextDevCycleParams "" "$TEGONAL_GITHUB_COMMONS_VERSION"

	local -a prepareFilesNextDevCycleTemplateArgs
	addLocalVarMatchingParamNamesToArgs prepareFilesNextDevCycleTemplateParams prepareFilesNextDevCycleTemplateArgs

	function prepare_next_afterVersionHook() {
		source "$dir_of_tegonal_scripts/releasing/params/after-version-update-hook.params.source.sh" || traceAndDie "could not source after-version-update-hook.params.source.sh"
		source "$dir_of_tegonal_scripts/releasing/params/after-version-update-hook.params-definition.source.sh" || traceAndDie "could not source after-version-update-hook.params-definition.source.sh"
		parseArguments afterVersionHookParams "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@" || return $?
		exitIfNotAllArgumentsSet afterVersionHookParams "" "$TEGONAL_GITHUB_COMMONS_VERSION"

		updateVersionInNonShFiles -v "$version-SNAPSHOT" --project-dir "$projectsRootDir"
	}

	# similar as in release.sh, you might need to update it there as well if you change something here
	local -r ownAdditionalPattern="(TEGONAL_GITHUB_COMMONS_VERSION=['\"])[^'\"]+(['\"])"

	prepareFilesNextDevCycleTemplate "${prepareFilesNextDevCycleTemplateArgs[@]}" \
		"$additionalPatternParamPatternLong" "$ownAdditionalPattern" \
		"$afterVersionUpdateHookParamPatternLong" prepare_next_afterVersionHook

}

${__SOURCED__:+return}
prepareNextDevCycle "$@"
