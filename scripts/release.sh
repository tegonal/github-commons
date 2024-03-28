#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v2.4.0-SNAPSHOT
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH
TEGONAL_GITHUB_COMMONS_VERSION="v2.3.0"

if ! [[ -v scriptsDir ]]; then
	scriptsDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)"
	readonly scriptsDir
fi

if ! [[ -v projectDir ]]; then
	projectDir="$(realpath "$scriptsDir/../")"
	readonly projectDir
fi

if ! [[ -v dir_of_github_commons ]]; then
	dir_of_github_commons="$projectDir/src"
	readonly dir_of_github_commons
fi

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$projectDir/lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$dir_of_tegonal_scripts/releasing/release-files.sh"
sourceOnce "$scriptsDir/before-pr.sh"
sourceOnce "$scriptsDir/prepare-next-dev-cycle.sh"
sourceOnce "$scriptsDir/update-version-in-non-sh-files.sh"

function release() {
	source "$dir_of_tegonal_scripts/releasing/common-constants.source.sh" || die "could not source common-constants.source.sh"

	local version
	# shellcheck disable=SC2034   # they seem unused but are necessary in order that parseArguments doesn't create global readonly vars
	local key branch nextVersion prepareOnly
	# shellcheck disable=SC2034   # is passed by name to parseArguments
	local -ra params=(
		version "$versionParamPattern" "$versionParamDocu"
		key "$keyParamPattern" "$keyParamDocu"
		branch "$branchParamPattern" "$branchParamDocu"
		nextVersion "$nextVersionParamPattern" "$nextVersionParamDocu"
		prepareOnly "$prepareOnlyParamPattern" "$prepareOnlyParamDocu"
	)
	parseArguments params "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@"

	function findFilesToRelease() {
		find "$projectDir/src" \
			-not -name "*.doc.sh" \
			"$@"
	}

	function release_afterVersionHook() {
		local version projectsRootDir additionalPattern
		parseArguments afterVersionHookParams "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@"

		updateVersionInNonShFiles -v "$version" --project-dir "$projectsRootDir"

		# cleanup-on-push-to-main relies on the latest version, i.e. we need to re-source the file in order that this change
		# is taken into account as well
		sourceAlways "$scriptsDir/cleanup-on-push-to-main.sh"
	}

	# similar as in prepare-next-dev-cycle.sh, you might need to update it there as well if you change something here
	local -r additionalPattern="(TEGONAL_GITHUB_COMMONS_(?:LATEST_)?VERSION=['\"])[^'\"]+(['\"])"
	releaseFiles \
		--project-dir "$projectDir" \
		--pattern "$additionalPattern" \
		"$@" \
		--sign-fn findFilesToRelease \
		--after-version-update-hook release_afterVersionHook
}

${__SOURCED__:+return}
release "$@"
