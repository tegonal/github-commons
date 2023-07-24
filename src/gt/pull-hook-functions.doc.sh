#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
MY_PROJECT_LATEST_VERSION="v1.0.0"

# Assumes tegonal's github-commons was fetched with gt - adjust location accordingly
dir_of_github_commons="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)/../lib/tegonal-gh-common/src"

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$dir_of_github_commons/../tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi

source "$dir_of_github_commons/gt/pull-hook-functions.sh"

declare _tag=$1 source=$2 _target=$3
shift 3 || die "could not shift by 3"

replacePlaceholdersContributorsAgreement "$source" "my-project-name" "MyCompanyName, Country"
replacePlaceholdersPullRequestTemplate "$source" "https://github.com/tegonal/my-project-name" "$MY_PROJECT_LATEST_VERSION"

# also have a look at https://github.com/tegonal/gt/blob/main/.gt/remotes/tegonal-scripts/pull-hook.sh
