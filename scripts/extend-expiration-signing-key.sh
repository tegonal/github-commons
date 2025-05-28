#!/usr/bin/env bash
#
#   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v3.1.0-SNAPSHOT
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
	dir_of_tegonal_scripts="$scriptsDir/../lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi

function extendExpirationSigningKey() {
	local tmpDir
	tmpDir=$(mktemp -d -t signing-key-XXXXXXXXXX)
	local -r gpgDir="$tmpDir/gpg"

	# we want to evaluate it now as it will not change afterwards and tmpDir might be out of scope afterwards
	# shellcheck disable=SC2064
	trap "[[ -d '$tmpDir' ]] && rm -r '$tmpDir'" EXIT

	function setupTmpDir() {
		! [[ -d "$tmpDir" ]] && mkdir "$tmpDir"
		mkdir "$gpgDir"
		chmod 700 "$gpgDir"
	}

	function importGpgViaClipboard() {
		local -r keyId=$2
		echo "copy the private key of $keyId into your clipboard and press enter"
		read -r
		xclip -o -sel clipboard >"$tmpDir/$keyId.asc"
		gpg --homedir "$gpgDir" --import "$tmpDir/$keyId.asc"

		gpg --homedir "$gpgDir" --list-secret-keys
	}

	local -r signingKey="$dir_of_github_commons/gt/signing-key.public.asc"
	local -r actualSig="$dir_of_github_commons/gt/signing-key.public.asc.actual_sig"

	setupTmpDir
	gpg --homedir "$gpgDir" --import "$signingKey"
	importGpgViaClipboard "$tmpDir" 6B82BB2BECEE0447
	printf "key 945FE615904E5C85\nexpire\n1y\nsave\n" |
		gpg --homedir "$gpgDir" --batch --command-fd 0 --edit-key 6B82BB2BECEE0447
	gpg --homedir "$gpgDir" --export --armor 6B82BB2BECEE0447 >"$signingKey"
	rm -r "$tmpDir"

	setupTmpDir
	importGpgViaClipboard "$tmpDir" 4B78012139378220
	gpg --homedir "$gpgDir" --detach-sign -u 4B78012139378220 --output "$actualSig" "$signingKey"
	rm -r "$tmpDir"

	"$scriptsDir/before-pr.sh"

	logSuccess "expiration date for %s updated and signed (%s) and copied to the .gt directory" "$signingKey" "$actualSig"

}

${__SOURCED__:+return}
extendExpirationSigningKey "$@"
