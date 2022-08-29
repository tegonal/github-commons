#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Creative Commons Zero v1.0 Universal
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v0.2.0-SNAPSHOT
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

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$scriptsDir/../lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$scriptsDir/run-shellcheck.sh"

function beforePr() {
	customRunShellcheck
	cp -r "$projectDir"/src/.github/* "$projectDir/.github/"
	perl -0777 -i -pe "s/<PROJECT_NAME>/github-commons/g" "$projectDir/.github/Contributor Agreement v1.1.txt"
	perl -0777 -i -pe "s#<GITHUB_URL>#https://github.com/tegonal/github-commons#g" "$projectDir/.github/PULL_REQUEST_TEMPLATE.md"
	perl -0777 -i -pe "s@name: \"Shellcheck\"@#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n# DO NOT MODIFY HERE BUT IN ./src/.github/workflows/shellckeck.yml\n#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nname: \"Shellcheck\"@" \
		"$projectDir/.github/workflows/shellcheck.yml"
}

${__SOURCED__:+return}
beforePr "$@"
