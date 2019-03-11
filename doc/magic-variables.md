# Magic Variables

Some variables are replaced with calculated values on each build. These are:

* `__DEPENDENCIES__`: Replaced with Object:

        root: <- root project's properties
            commit: "the-git-commit-hash"
            dirty: true/false
            count: commit count of the branch
