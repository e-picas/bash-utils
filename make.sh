#!/usr/bin/env bash
#
# <http://gitlab.com/piwi/bash-utils>
# Copyright (c) 2015 Pierre Cassat & contributors
# License Apache 2.0 - This program comes with ABSOLUTELY NO WARRANTY.
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code or see <http://www.apache.org/licenses/LICENSE-2.0>.
#
# bash-utils make: install / cleanup / rebuild manpages / upgrade version / create release / test / validate
#
set -eETu

resolve_link() {
    $(type -p greadlink readlink | head -1) "$1"
}

abs_dirname() {
    local cwd="$(pwd)"
    local path="$1"

    while [ -n "$path" ]; do
        cd "${path%/*}"
        local name="${path##*/}"
        path="$(resolve_link "$name" || true)"
    done

    pwd
    cd "$cwd"
}

usage() {
    {   echo "usage: $0 install <prefix>"
        echo "       $0 cleanup <prefix>"
        echo "       $0 manpages"
        echo "       $0 version <version>"
        echo "       $0 release <version>"
        echo "       $0 test"
        echo "       $0 validate"
        echo
        echo "  e.g. $0 install /usr/local"
        echo "       $0 cleanup /usr/local"
    } >&2
    exit 1
}

make_cleanup()
{
    ( [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ] ) && { echo "Invalid prefix '$PREFIX'. Aborting." >&2; exit 1; }
    rm -rf "$PREFIX"/{bin,libexec,share/man/{man1,man7}}/bash-utils*
    return $?
}

make_install()
{
    ( [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ] ) && { echo "Invalid prefix '$PREFIX'. Aborting." >&2; exit 1; }
    mkdir -p "$PREFIX"/{bin,libexec,share/man/{man1,man7}}
    cp -R "$ROOT_DIR"/bin/* "$PREFIX"/bin/
    cp -R "$ROOT_DIR"/libexec/* "$PREFIX"/libexec/
    cp "$ROOT_DIR"/man/bash-utils.1.man "$PREFIX"/share/man/man1/
    cp "$ROOT_DIR"/man/bash-utils.7.man "$PREFIX"/share/man/man7/
    return $?
}

make_manpages()
{
    command -v markdown-extended >/dev/null 2>&1 || { echo "Markdown-extended command not found. Aborting." >&2; exit 1; }
    markdown-extended --force -f man -o "${ROOT_DIR}/man/bash-utils.1.man" "${ROOT_DIR}/man/MANPAGE.1.md"
    markdown-extended --force -f man -o "${ROOT_DIR}/man/bash-utils.7.man" "${ROOT_DIR}/man/MANPAGE.7.md"
    return $?
}

make_version()
{
    [ -z "$VERSION" ] && { echo "Invalid version number '$VERSION'. Aborting." >&2; exit 1; }
    sed -i -e "s| BASH_UTILS_VERSION='.*'| BASH_UTILS_VERSION='${VERSION}'|" "${ROOT_DIR}/libexec/bash-utils-core/bash-utils-core" \
        && sed -i -e "s|^Version: .*$|Version: ${VERSION}|;s|^Date: .*$|Date: ${DATE}|" "${ROOT_DIR}/man/MANPAGE.1.md" \
        && sed -i -e "s|^Version: .*$|Version: ${VERSION}|;s|^Date: .*$|Date: ${DATE}|" "${ROOT_DIR}/man/MANPAGE.7.md" \
        || { echo "An error occurred." >&2; exit 1; };
    return $?
}

make_release()
{
    [ -z "$VERSION" ] && { echo "Invalid version number '$VERSION'. Aborting." >&2; exit 1; }
    TAGNAME="v${VERSION}"
    git stash save 'pre-release stashing'
    git checkout master
    $0 version "$VERSION"
    $0 manpages
    git commit -am "Upgrade app to $VERSION (automatic commit)"
    git tag "$TAGNAME" -m "New release $VERSION (automatic tag)"
    git stash pop
    return $?
}

make_tests()
{
    command -v bats >/dev/null 2>&1 || { echo "BATS command not found. Aborting." >&2; exit 1; }
    bats "$ROOT_DIR"/test/*.bats
    return $?
}

make_check()
{
    command -v shellcheck >/dev/null 2>&1 || { echo "ShellCheck command not found. Aborting." >&2; exit 1; }
    for f in $(find "$ROOT_DIR"/libexec/ -type f); do
        shellcheck --shell=bash --exclude=SC2034,SC2016 "$f" || true;
    done
    return $?
}

declare ROOT_DIR ACTUAL_VERSION DATE VERSION TAGNAME PREFIX
ROOT_DIR="$(abs_dirname "$0")"
ACTUAL_VERSION="$("${ROOT_DIR}/bin/bash-utils" -qV)"
if [ -d "${ROOT_DIR}/.git" ]; then
    DATE=$(git log -1 --format="%ci" --date=short | cut -s -f 1 -d ' ')
else
    DATE="$(date +'%Y-%m-%d')"
fi

[ $# -eq 0 ] && usage;
case "$1" in
    install)
        [ $# -lt 2 ] && usage;
        PREFIX="${2%/}"
        make_cleanup && make_install && echo "Installed Bash-Utils to $PREFIX/bin/bash-utils.bash";
        ;;
    cleanup)
        [ $# -lt 2 ] && usage;
        PREFIX="${2%/}"
        make_cleanup && echo "Removed Bash-Utils from $PREFIX/bin/";
        ;;
    manpages)
        make_manpages && echo "Manpages regenerated in $ROOT_DIR/man/";
        ;;
    version)
        echo "current version is: ${ACTUAL_VERSION}"
        [ $# -lt 2 ] && usage;
        VERSION="$2"
        make_version && echo "Version number updated in library and manpages";
        ;;
    release)
        echo "current version is: ${ACTUAL_VERSION}"
        [ $# -lt 2 ] && usage;
        VERSION="$2"
        make_release && echo "Released tag v${VERSION} - nothing pushed to remote(s)";
        ;;
    test) make_tests;;
    validate) make_check;;
    *) usage;;
esac

exit 0
# vim: autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 filetype=sh
