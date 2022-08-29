<!-- for main -->
<!--
[![Download](https://img.shields.io/badge/Download-v0.1.2-%23007ec6)](https://github.com/tegonal/github-commons/releases/tag/v0.1.2)
[![Creative Commons Zero v1.0 Universal](https://img.shields.io/badge/%E2%9A%96-Apache%202.0-%230b45a6)](https://creativecommons.org/publicdomain/zero/1.0/ "License")
[![Code Quality](https://github.com/tegonal/github-commons/workflows/Scripts%20Code%20Quality/badge.svg?event=push&branch=main)](https://github.com/tegonal/github-commons/actions/workflows/scripts-quality.yml?query=branch%3Amain)
[![Newcomers Welcome](https://img.shields.io/badge/%F0%9F%91%8B-Newcomers%20Welcome-blueviolet)](https://github.com/tegonal/github-commons/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22 "Ask in discussions for help")
-->
<!-- for main end -->
<!-- for release -->

[![Download](https://img.shields.io/badge/Download-v0.1.2-%23007ec6)](https://github.com/tegonal/github-commons/releases/tag/v0.1.2)
[![Creative Commons Zero v1.0 Universal](https://img.shields.io/badge/%E2%9A%96-Apache%202.0-%230b45a6)](https://creativecommons.org/publicdomain/zero/1.0/ "License")
[![Newcomers Welcome](https://img.shields.io/badge/%F0%9F%91%8B-Newcomers%20Welcome-blueviolet)](https://github.com/tegonal/github-commons/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22 "Ask in discussions for help")

<!-- for release end -->

# Tegonal's github-commons

This repository contains files we are (re-)using in our OSS work published on github.  
Feel free to use them as well, they are licensed under [Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).  
(Take also a look at our bash [scripts](https://github.com/tegonal/scripts) which are licensed under Apache 2.0)

Typically, we fetch the files of this repository via [gget](https://github.com/tegonal/gget) into our projects.  
If you want to fetch them with gget as well then set up a corresponding remote
```bash
gget remote add -r tegonal-gh-commons -u https://github.com/tegonal/github-commons
````

Now you can pull the files you want. For instance, to retrieve the dependabot.yml and put it into .github
```bash
gget pull -r tegonal-gh-commons -p .github/dependabot.yml --chop-path true -d .github
```

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
