#!/bin/bash

#### Declare usage

usage()
{
	cat <<- _EOF_
		Usage: ./aurpublish [OPTIONS] PACKAGE
		Push a subtree to the AUR

		OPTIONS
		    -p, --pull      Instead of publishing, pull changes from the AUR.
		                      Can import packages into a new subtree.
		    -s, --speedup   Speedup future publishing by recording the subtree
		                      history during a push. This creates a merge commit
		                      and a second copy of all commits in the subtree.
		                      For more details, see the "--rejoin" option in git
		                      subtree.
		    -h, --help      Show this usage message

		COMMANDS
		    log             Display the git log of a single package. This is only
		                      useful if changes were pulled from the AUR (because
		                      \`git log\` isn't very good at reading subtrees).
_EOF_
}

## Function to test if package is already committed in git
is_package_in_git()
{
    git ls-tree -d --name-only HEAD | grep -E "^${1}$" > /dev/null 2>&1
}

#### Do the great option check

if [[ $# -eq 0 ]]; then
    echo "error: No arguments passed. aurpublish needs a package to upload."
    exit 1
fi
while [[ "${1}" != "" ]]; do
    case ${1} in
        -h|--help)
            usage
            exit
            ;;
        -p|--pull)
            pull_subtree=1
            shift
            package="${1%/}"
            ;;
        -s|--speedup)
            speedup=1
            ;;
        log)
            shift
            package="${1%/}"
            shift
            git log $(git subtree split -P $package) "$@"
            exit
            ;;
        *)
            if is_package_in_git ${1%/}; then
                package="${1%/}"
            else
                echo "${0}: unrecognized package '${1}'"
                echo "Try '${0} --help' for more information."
                exit 1
            fi
    esac
    shift
done

#### MAIN

if [[ "${pull_subtree}" = "1" ]]; then
    # test if prefix already exists
    if is_package_in_git ${package}; then
        git subtree split -P "${package}" --rejoin
        git subtree pull -P "${package}" aur:${package}.git master -m "Merge subtree '${package}'"
    else
        git subtree add -P "${package}" aur:${package}.git master
    fi
    exit 0
fi

if [[ "${speedup}" = "1" ]]; then
    git subtree split -P "${package}" --rejoin
fi
git subtree push -P "${package}" aur:${package}.git master