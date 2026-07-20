#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal/github-commons
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        It is licensed under Apache License 2.0
#  \__/\__/\_, /\___/_//_/\_,_/_/         Please report bugs and contribute back your improvements
#         /___/
#                                         Version: v1.2.0-SNAPSHOT
#
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH

if ! [[ -v scriptsDir ]]; then
	scriptsDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)/../../../scripts"
	readonly scriptsDir
fi
source "$scriptsDir/dirs.source.sh"
sourceOnce "$dir_of_github_commons/gt/pull-hook-functions.sh"
sourceOnce "$dir_of_tegonal_scripts/utility/parse-fn-args.sh"

function gt_pullHook_random_matrix_before() {
	# no op, nothing to do
	:
}

function gt_pullHook_random_matrix_after() {
	# no op, nothing to do
	local _tag source target
	# shellcheck disable=SC2034   # is passed to parseFnArgs by name
	local -ra params=(_tag source target)
	parseFnArgs params "$@"

	local -r builder="$projectDir/src/.github/workflows/vlsi_matrix_builder.mjs"

	function insertIntoVlsiMatrixBuilder() {
		perl -0pi - "$builder" <<-PERL
			BEGIN {
			  open my \$fh, '<', '$target' or die "\$!";
			  local \$/;
			  \$replacement = <\$fh>;

			  \$name = '$target';
			  \$name =~ s#.*/##;

			  \$start = "// BEGIN INSERTED \$name";
			  \$end   = "// END INSERTED \$name";
			}

			s#(\Q\$start\E).*?(\Q\$end\E)#\$1 . "\n" . \$replacement . "\n" . \$2#se;
		PERL
		rm "$target"
	}

	if [[ $source =~ /seedrandom.cjs ]]; then
		insertIntoVlsiMatrixBuilder
	elif [[ $source =~ /github_matrix_builder.mjs ]]; then
		insertIntoVlsiMatrixBuilder
		perl -pi -e "s#^(\s*(?:import \{ MatrixBuilder, Axis \} from './matrix_builder\.mjs';|const seedrandom = require\('./seedrandom\.cjs'\);|export \{ MatrixBuilder, Axis \};))#//\$1#m" "$builder"
	elif [[ $source =~ /matrix_builder.mjs ]]; then
		echo "da"
		insertIntoVlsiMatrixBuilder
	fi

}
