#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v2.6.0
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH
TEGONAL_GITHUB_COMMONS_VERSION="v2.6.0"

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
	dir_of_tegonal_scripts="$scriptsDir/../lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$dir_of_tegonal_scripts/utility/parse-args.sh"

function updateVersionInNonShFiles() {
	source "$dir_of_tegonal_scripts/releasing/common-constants.source.sh" || die "could not source common-constants.source.sh"
	local version projectsRootDir
	# shellcheck disable=SC2034   # is passed by name to parseArguments
	local -ra params=(
  	version "$versionParamPattern" "$versionParamDocu"
  	projectsRootDir "$projectsRootDirParamPattern" "$projectsRootDirParamDocu"
  )
	parseArguments params "" "$TEGONAL_GITHUB_COMMONS_VERSION" "$@"

	logInfo "going to update version in non-sh files to %s" "$version"

	find "$projectsRootDir/src" -type f \
		-not -name "*.sh" -print0 |
		while read -r -d $'\0' file; do
			perl -0777 -i -pe "s@((?:#|//) {4,}Version: ).*@\${1}$version@g;" "$file"
		done
}

${__SOURCED__:+return}
updateVersionInNonShFiles "$@"
