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

if ! [[ -v scriptsDir ]]; then
	scriptsDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)"
	readonly scriptsDir
fi
source "$scriptsDir/dirs.source.sh"

sourceOnce "$scriptsDir/run-shellcheck.sh"
sourceOnce "$scriptsDir/cleanup-on-push-to-main.sh"

function beforePr() {
	# using && because this function is used on the left side of an || in releaseFiles
	# this way we still have fail fast behaviour and don't mask/hide a non-zero exit code
	customRunShellcheck &&
		cleanupOnPushToMain
}

${__SOURCED__:+return}
beforePr "$@"
