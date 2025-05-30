#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
MY_PROJECT_LATEST_VERSION="v1.0.0"

# Assumes tegonal's github-commons was fetched with gt and put into repoRoot/lib/tegonal-gh-commons/src
dir_of_github_commons="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)/../../../lib/tegonal-gh-commons/src"

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$dir_of_github_commons/../../tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi

source "$dir_of_github_commons/gt/pull-hook-functions.sh"

# tegonal's github-commons was fetched with gt and remote is named tegonal_gh_commons
function gt_pullHook_tegonal_gh_commons_before() {
	local _tag=$1 source=$2 _target=$3
	shift 3 || die "could not shift by 3"

	# replaces placeholders in all files github-commons provides with placeholders
	replaceTegonalGhCommonsPlaceholders "$source" "my-project-name" "$MY_PROJECT_LATEST_VERSION" \
		"MyCompanyName, Country" "code-of-conduct@my-company.com" "my-companies-github-name" "my-project-github-name"
}

function gt_pullHook_tegonal_gh_commons_after() {
	# no op, nothing to do (or replace with your logic)
	:
}
