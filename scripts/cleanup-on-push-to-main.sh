#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v5.1.0-SNAPSHOT
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH
TEGONAL_GITHUB_COMMONS_LATEST_VERSION="v5.0.0"

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
sourceOnce "$dir_of_tegonal_scripts/utility/cleanups.sh"
sourceOnce "$dir_of_github_commons/gt/pull-hook-functions.sh"
sourceOnce "$dir_of_tegonal_scripts/utility/update-bash-docu.sh"
sourceOnce "$scriptsDir/run-shfmt.sh"

function cleanup_putWarning() {
	local -r findCommand=$1
	local -r dir=$2
	eval "$findCommand -type f -print0" |
		while read -r -d $'\0' file; do
			local relative
			relative=$(realpath --relative-to="$projectDir" "$file")
			perl -0777 -i -pe "s@(####+)@\${1}\n#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n# DO NOT MODIFY HERE BUT IN $dir/$relative\n#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!@" \
				"$file" || returnDying "could not put a warning notice into file %s" "$file" || return $?
		done || die "could not put the warning DO NOT MODIFY HERE into files, see above"
}

function cleanupOnPushToMain() {
	customRunShfmt || die "was not able to format"
	removeUnusedSignatures "$projectDir" || die "was not able to remove unused signatures"

	find "$dir_of_github_commons/dotfiles" -type f -name ".*" -not -name '.*.sig' -print0 |
		while read -r -d $'\0' file; do
			cp "$file" "$projectDir/" || return $?
		done || die "could not copy dotfiles to projectDir"

	cp "$dir_of_github_commons/gt/signing-key.public.asc" "$projectDir/.gt/signing-key.public.asc"
	cp "$dir_of_github_commons/gt/signing-key.public.asc.actual_sig" "$projectDir/.gt/signing-key.public.asc.sig"

	cp -r "$dir_of_github_commons"/.github/* "$projectDir/.github/" || die "could not copy files to .github"
	find "$projectDir/.github" -type f -name "*.sig" -exec rm -f {} \; || true
	rm "$projectDir/.github/workflows/matrix_builder.js"
	rm "$projectDir/.github/workflows/matrix_commons.js"

	local tegonalFullName tegonalEmail tegonalGithubName
	source "$dir_of_github_commons/gt/tegonal.data.source.sh" || die "could not source tegonal.data.source.sh"

	replacePlaceholdersCodeOfConduct "$projectDir/.github/CODE_OF_CONDUCT.md" "$tegonalEmail" || die "could not fill the placeholders of code of conduct template"
	replacePlaceholdersContributorsAgreement "$projectDir/.github/Contributor Agreement.txt" "github-commons" "github-commons" "$tegonalFullName" "$tegonalGithubName" || die "could not fill the placeholders of contributors agreement template"
	replacePlaceholdersPullRequestTemplate "$projectDir/.github/PULL_REQUEST_TEMPLATE.md" "https://github.com/tegonal/github-commons" "$TEGONAL_GITHUB_COMMONS_LATEST_VERSION" || die "could not fill the placeholders in PULL_REQUEST_TEMPLATE.md"
	cleanup_putWarning "find \"$projectDir/.github\" -not -name quality-assurance.yml -not -name gt-update.yml" "src"
	cleanup_putWarning "find \"$projectDir\" -maxdepth 1 -name '.*'" "src/dotfiles"

	perl -0777 -i -pe 's@\n( +)(#gt-placeholder-install-dependencies-start\n)@\n$1$2$1- name: install shfmt\n$1  run: ./lib/tegonal-scripts/src/ci/install-shfmt.sh\n@' "$projectDir/.github/workflows/cleanup.yml"

	find "$dir_of_github_commons" -type f \
		-name "*.sh" \
		-not -name "*.doc.sh" \
		-not -name "*.source.sh" \
		-not -name "docker-entrypoint.sh" \
		-print0 |
		while read -r -d $'\0' script; do
			relative="$(realpath --relative-to="$projectDir" "$script")"
			declare id="${relative:4:-3}"
			updateBashDocumentation "$script" "${id////-}" . README.md || return $?
		done || die "updating bash documentation failed, see above"

	logSuccess "cleanup complete"
}

${__SOURCED__:+return}
cleanupOnPushToMain "$@"
