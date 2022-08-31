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
TEGONAL_GITHUB_COMMONS_LATEST_VERSION="v0.1.2"

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
	dir_of_tegonal_scripts="$scriptsDir/../lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$scriptsDir/run-shellcheck.sh"
sourceOnce "$dir_of_github_commons/gget/pull-hook-functions.sh"
sourceOnce "$dir_of_tegonal_scripts/utility/update-bash-docu.sh"

function beforePr() {
	customRunShellcheck
	cp -r "$dir_of_github_commons"/.github/* "$projectDir/.github/"

	# same as in additional-release-files-preparations.sh
  declare githubUrl="https://github.com/tegonal/github-commons"

	replacePlaceholdersContributorsAgreement "$projectDir/.github/Contributor Agreement.txt" "github-commons"
	replacePlaceholderPullRequestTemplate "$projectDir/.github/PULL_REQUEST_TEMPLATE.md" "$githubUrl" "$TEGONAL_GITHUB_COMMONS_LATEST_VERSION"
	perl -0777 -i -pe "s@name: \"Shellcheck\"@#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n# DO NOT MODIFY HERE BUT IN ./src/.github/workflows/shellckeck.yml\n#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nname: \"Shellcheck\"@" \
		"$projectDir/.github/workflows/shellcheck.yml"

	find "$dir_of_github_commons" -type f \
			-name "*.sh" \
  		-not -name "*.doc.sh" \
  		-print0 |
		while read -r -d $'\0' script; do
			relative="$(realpath --relative-to="$projectDir" "$script")"
			declare id="${relative:4:-3}"
			updateBashDocumentation "$script" "${id////-}" . README.md
		done
}

${__SOURCED__:+return}
beforePr "$@"
