#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Creative Commons Zero v1.0 Universal
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.7.0-SNAPSHOT
#
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

if ! [[ -v dir_of_github_commons ]]; then
	dir_of_github_commons="$projectDir/src"
	readonly dir_of_github_commons
fi

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$projectDir/lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$dir_of_github_commons/gget/pull-hook-functions.sh"

if ! [[ -v version ]] || [[ -z $version ]]; then
	die "looks like \$version was not defined by release-files.sh where this file is supposed to be sourced."
fi

function additionalReleasePrepareSteps() {
	logInfo "going to update version in non-sh files to %s" "$version"

	find "$projectDir/src" -type f \
		-not -name "*.sh" -print0 |
		while read -r -d $'\0' file; do
			perl -0777 -i -pe "s/(# {4,}Version: ).*/\${1}$version/g;" "$file"
		done

	# cleanup-on-push-to-main relies the latest version, i.e. we need to re-source the file in order that this change
	# is taken into account as well
	sourceAlways "$scriptsDir/cleanup-on-push-to-main.sh"
}

additionalReleasePrepareSteps
