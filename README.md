<!-- for main -->
<!--
[![Download](https://img.shields.io/badge/Download-v0.2.0-%23007ec6)](https://github.com/tegonal/github-commons/releases/tag/v0.2.0)
[![Creative Commons Zero v1.0 Universal](https://img.shields.io/badge/%E2%9A%96-Apache%202.0-%230b45a6)](https://creativecommons.org/publicdomain/zero/1.0/ "License")
[![Code Quality](https://github.com/tegonal/github-commons/workflows/Scripts%20Code%20Quality/badge.svg?event=push&branch=main)](https://github.com/tegonal/github-commons/actions/workflows/scripts-quality.yml?query=branch%3Amain)
[![Newcomers Welcome](https://img.shields.io/badge/%F0%9F%91%8B-Newcomers%20Welcome-blueviolet)](https://github.com/tegonal/github-commons/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22 "Ask in discussions for help")
-->
<!-- for main end -->
<!-- for release -->

[![Download](https://img.shields.io/badge/Download-v0.2.0-%23007ec6)](https://github.com/tegonal/github-commons/releases/tag/v0.2.0)
[![Creative Commons Zero v1.0 Universal](https://img.shields.io/badge/%E2%9A%96-Apache%202.0-%230b45a6)](https://creativecommons.org/publicdomain/zero/1.0/ "License")
[![Newcomers Welcome](https://img.shields.io/badge/%F0%9F%91%8B-Newcomers%20Welcome-blueviolet)](https://github.com/tegonal/github-commons/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22 "Ask in discussions for help")

<!-- for release end -->

# Tegonal's github-commons

This repository contains files we are (re-)using in our OSS work published on github.  
Feel free to use them as well, they are licensed under [Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).  
(Take also a look at our bash [scripts](https://github.com/tegonal/scripts) which are licensed under Apache 2.0)

**Table of Content**
- [How to use it](#how-to-use-it)
- [Contributors and contribute](#contributors-and-contribute)
- [License](#license)


# How to use it

Typically, we fetch the files of this repository via [gget](https://github.com/tegonal/gget) into our projects.  
If you want to fetch them with gget as well then set up a corresponding remote
```bash
gget remote add -r tegonal-gh-commons -u https://github.com/tegonal/github-commons
````

Now you can pull the files you want. For instance, to retrieve the dependabot.yml and put it into .github
```bash
gget pull -r tegonal-gh-commons -p src/.github/dependabot.yml --chop-path true -d .github
```

# Placeholders

Some files contain placeholders which you should replace.
We provide bash functions which you can source into your pull-hook.sh and use to fill those.
Get them was well via gget
```
gget pull -r tegonal-gh-commons -p src/gget/pull-hook-functions.sh
```

However, they require the utility functions of [tegonal-scripts](https://github.com/tegonal/scripts) to be fetched alongside of github-commons.
Thus, if you have not already pulled tegonal-scripts, then [gget them](https://github.com/tegonal/scripts#Installation]).

And then in your pull-hook.sh you can use it as follows:

<gget-pull-hook-functions>

<!-- auto-generated, do not modify here but in src/gget/pull-hook-functions.sh -->
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
MY_PROJECT_LATEST_VERSION="v1.0.0"

# Assumes tegonal's github-commons was fetched with gget - adjust location accordingly
dir_of_github_commons="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)/../lib/tegonal-gh-common/src"

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$dir_of_github_commons/../tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi

source "$dir_of_github_commons/gget/pull-hook-functions.sh"

declare _tag=$1 source=$2 _target=$3
shift 3 || die "could not shift by 3"

replacePlaceholdersContributorsAgreement "$source" "my-project-name"
replacePlaceholderPullRequestTemplate "$source" "https://github.com/tegonal/my-project-name" "$MY_PROJECT_LATEST_VERSION"

# also have a look at https://github.com/tegonal/gget/blob/main/.gget/remotes/tegonal-scripts/pull-hook.sh
```

</gget-pull-hook-functions>

# Contributors and contribute

Our thanks go to [code contributors](https://github.com/tegonal/github-commons/graphs/contributors)
as well as all other contributors (e.g. bug reporters, feature request creators etc.)

You are more than welcome to contribute as well:

- star this repository if you like/use it
- [open a bug](https://github.com/tegonal/github-commons/issues/new?template=bug_report.md) if you find one
- Open a [new discussion](https://github.com/tegonal/github-commons/discussions/new?category=ideas) if you are missing a
  feature
- [ask a question](https://github.com/tegonal/github-commons/discussions/new?category=q-a)
  so that we better understand where our scripts need to improve.
- have a look at
  the [help wanted issues](https://github.com/tegonal/github-commons/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22).

# License

The provided scripts are licensed under [Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).
