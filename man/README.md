The final manpages files are generated from the `MANPAGE.X.md` markdown content
with the help of <http://github.com/piwi/markdown-extended>.

To generate it, run:

        markdown-extended -f man -o man/bash-utils.X.man man/MANPAGE.X.md
        man man/bash-utils.X.man

Or use the `make.sh` script:

    ./make.sh manpages
