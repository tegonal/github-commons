#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v2.2.0-SNAPSHOT
#######  Description  #############
#
#  functions which can be used to update the placeholders in the templates in a gt pull-hook.sh
#
#######  Usage  ###################
#
#    #!/usr/bin/env bash
#    set -euo pipefail
#    shopt -s inherit_errexit
#    MY_PROJECT_LATEST_VERSION="v1.0.0"
#
#    # Assumes tegonal's github-commons was fetched with gt and put into repoRoot/.gt/remotes/tegonal-gh-commons/lib
#    # - adjust remote name or location accordingly
#    dir_of_github_commons="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)/lib/src"
#
#    if ! [[ -v dir_of_tegonal_scripts ]]; then
#    	dir_of_tegonal_scripts="$dir_of_github_commons/../tegonal-scripts/src"
#    	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
#    fi
#
#    source "$dir_of_github_commons/gt/pull-hook-functions.sh"
#
#    declare _tag=$1 source=$2 _target=$3
#    shift 3 || die "could not shift by 3"
#
#    # replaces placeholders in all files github-commons provides with placeholders
#    replaceTegonalGhCommonsPlaceholders "$source" "my-project-name" "$MY_PROJECT_LATEST_VERSION" \
#    	"MyCompanyName, Country"  "code-of-conduct@my-company.com" "my-companies-github-name" "my-project-github-name"
#
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH

if ! [[ -v dir_of_github_commons ]]; then
	dir_of_github_commons="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)/.."
	readonly dir_of_github_commons
fi

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$dir_of_github_commons/../tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi

sourceOnce "$dir_of_tegonal_scripts/utility/parse-fn-args.sh"

function replaceTegonalGhCommonsPlaceholders(){
	local source projectName version owner ownerEmail ownerGithubName projectNameGithub
	# shellcheck disable=SC2034   # is passed to parseFnArgs by name
	local -ra params=(source projectName version owner ownerEmail ownerGithubName projectNameGithub)
	parseFnArgs params "$@"

	if [[ $source =~ .*/\.github/CODE_OF_CONDUCT.md ]]; then
  			replacePlaceholdersCodeOfConduct "$source" "$ownerEmail"
	elif [[ $source =~ .*/\.github/Contributor[[:space:]]Agreement\.txt ]]; then
		replacePlaceholdersContributorsAgreement "$source" "$projectName" "$owner"
	elif [[ $source =~ .*/\.github/PULL_REQUEST_TEMPLATE.md ]]; then
		local -r githubUrl="https://github.com/$ownerGithubName/$projectNameGithub"
		replacePlaceholdersPullRequestTemplate "$source" "$githubUrl" "$version"
	fi
}

function replaceTegonalGhCommonsPlaceholders_Tegonal(){
	local source projectName version projectNameGithub
	# shellcheck disable=SC2034   # is passed to parseFnArgs by name
	local -ra params=(source projectName version projectNameGithub)
	parseFnArgs params "$@"


	local tegonalFullName tegonalEmail tegonalGithubName
	source "$dir_of_github_commons/gt/tegonal.data.source.sh" || die "could not source tegonal.data.source.sh"

	replaceTegonalGhCommonsPlaceholders "$source" "$projectName" "$version" "$tegonalFullName" "$tegonalEmail" "$tegonalGithubName" "$projectNameGithub"
}

function replacePlaceholdersContributorsAgreement() {
	if ! (($# == 3)); then
		logError "you need to pass three arguments to replacePlaceholdersContributorsAgreement"
		echo "1: file         represents the 'Contributor Agreement.txt'"
		echo "2: projectName  the name of the project"
		echo "3: owner				owner of the project"
		printStackTrace
		exit 9
	fi
	local -r file=$1
	local -r projectName=$2
	local -r owner=$3
	shift 3 || die "could not shift by 3"
	PROJECT_NAME="$projectName" OWNER="$owner" perl -0777 -i \
		-pe 's/<PROJECT_NAME>/$ENV{PROJECT_NAME}/g;' \
		-pe 's/<OWNER>/$ENV{OWNER}/g;' \
		"$file"
}

function replacePlaceholdersPullRequestTemplate() {
	if ! (($# == 3)); then
		logError "you need to pass three arguments to replacePlaceholdersPullRequestTemplate"
		echo "1: file        represents the 'PULL_REQUEST_TEMPLATE.md'"
		echo "2: url				 the github url"
		echo "3: latestTag   latest tag"
		printStackTrace
		exit 9
	fi
	local -r file=$1
	local -r url=$2
	local -r tag=$3
	shift 3 || die "could not shift by 3"
	TAG="$tag" GITHUB_URL="$url" perl -0777 -i \
		-pe 's#<GITHUB_URL>#$ENV{GITHUB_URL}#g;' \
		-pe 's#<TAG>#$ENV{TAG}#g;' \
		"$file"
}

function replacePlaceholdersCodeOfConduct(){
	if ! (($# == 2)); then
		logError "you need to pass two arguments to replacePlaceholdersCodeOfConductTemplate"
		echo "1: file         represents the 'CODE_OF_CONDUCT.md'"
		echo "2: owner_email	email address which should be contacted in case of a violation"
		printStackTrace
		exit 9
	fi
	local -r file=$1
	local -r ownerEmail=$2
	shift 2 || die "could not shift by 2"
	EMAIL="$ownerEmail" perl -0777 -i \
		-pe 's/<OWNER_EMAIL>/$ENV{EMAIL}/g;' \
		"$file"
}

function replaceTagInPullRequestTemplate() {
	if ! (($# == 3)); then
		logError "you need to pass three arguments to replaceTagInPullRequestTemplate"
		echo "1: file   represents the 'PULL_REQUEST_TEMPLATE.md'"
		echo "2: url	  the github url"
		echo "3: tag    tag to set in url"
		printStackTrace
		exit 9
	fi
	local -r file=$1
	local -r url=$2
	local -r tag=$3
	shift 3 || die "could not shift by 3"

	perl -0777 -i \
		-pe "s#($url/blob/)[^/]+/#\${1}$tag/#;" \
		"$file"
}
