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

sourceOnce "$dir_of_tegonal_scripts/releasing/release-files.sh"
sourceOnce "$scriptsDir/before-pr.sh"
sourceOnce "$scriptsDir/prepare-next-dev-cycle.sh"
sourceOnce "$scriptsDir/update-version-in-non-sh-files.sh"

function release() {
	source "$dir_of_tegonal_scripts/releasing/params/release-files.params.source.sh" || traceAndDie "could not source release-files.params.source.sh"
	source "$dir_of_tegonal_scripts/releasing/params/release-files.params-definition.source.sh" || traceAndDie "could not source release-files.params-definition.source.sh"
	parseArguments releaseFilesParams "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@" || return $?
	source "$dir_of_tegonal_scripts/releasing/params/release-files.default-args.source.sh" || die "could not source release-files.default-args.source.sh"
	exitIfNotAllArgumentsSet releaseFilesParams "" "$TEGONAL_GITHUB_COMMONS_VERSION"

	local -a releaseFilesTemplateArgs
	addLocalVarMatchingParamNamesToArgs releaseFilesTemplateParams releaseFilesTemplateArgs

	function findFilesToRelease() {
		find "$projectDir/src" \
			-not -name "*.doc.sh" \
			"$@"
	}

	function release_afterVersionHook() {
		source "$dir_of_tegonal_scripts/releasing/params/after-version-update-hook.params.source.sh" || traceAndDie "could not source after-version-update-hook.params.source.sh"
		source "$dir_of_tegonal_scripts/releasing/params/after-version-update-hook.params-definition.source.sh" || traceAndDie "could not source after-version-update-hook.params-definition.source.sh"
		parseArguments afterVersionHookParams "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@" || return $?
		exitIfNotAllArgumentsSet afterVersionHookParams "" "$TEGONAL_GITHUB_COMMONS_VERSION"

		updateVersionInNonShFiles -v "$version" --project-dir "$projectsRootDir"

		# cleanup-on-push-to-main relies on the latest version, i.e. we need to re-source the file in order that this change
		# is taken into account as well
		sourceAlways "$scriptsDir/cleanup-on-push-to-main.sh"
	}

	# similar as in prepare-next-dev-cycle.sh, you might need to update it there as well if you change something here
	local -r additionalPattern="(TEGONAL_GITHUB_COMMONS_(?:LATEST_)?VERSION=['\"])[^'\"]+(['\"])"

	releaseFilesTemplate \
		"$projectsRootDirParamPatternLong" "$projectDir" \
		"$additionalPatternParamPatternLong" "$additionalPattern" \
		"${releaseFilesTemplateArgs[@]}" \
		"$findForSigningParamPatternLong" findScripts \
		"$afterVersionUpdateHookParamPatternLong" release_afterVersionHook
}

${__SOURCED__:+return}
release "$@"
