Contribute to Bash-Utils
========================

If you want to contribute to this project, first you are very welcome ;) Then, this documentation
file will introduce you the "dev-cycle" of Bash-Utils.


Inform about a bug or request for a new feature
-----------------------------------------------

### Bug ticketing

A bug is a *demonstrable problem caused by the code* (and not due to a special user behaviour).
Bugs are inevitable and exist in all software. If you find one and want to transmit it, first
**it is very helpful** as it will participate to build a robust software.

But ... a bug report is helpful as long as it can be understood, reproduced, and that it permits to
identify the error (and what caused it). A good bug report MUST follow these guidelines:

-   **first**: search in the issue tracker if your bug has not been transmitted yet ; if you find an existing one,
    you can add a new comment to the appropriate thread with your experience if it seems different
    from the others ;
-   **then**: check if it exists right now: try to reproduce it with the current code to confirm it still exists ;
-   if you **finally** create a bug ticket, try to detail it as much as possible:
    -   what is your environment (application version, OS, device ...)?
    -   describe and comment the steps that brought you to that bug
    -   try to isolate the problem as much as possible
    -   what did you expect?

### Feature requests

If you want to ask for a new feature, please follow these guidelines:

-   the goal of this project is to be (and keep) relevant for a large public ; maybe your request
    is quite personal (you have a particular need) and can be discussed with me by email ; in this
    case please do not make a feature request (!)
-   if you think something is missing or have an idea to increase one of Bash-Utils's features, then
    you are ready for a "feature request" ; you can create an issue ticket beginning its name by
    "feature request: " ; please detail your request or your idea as much as possible, with a lot 
    of your experience.

Actually change the code
------------------------

First of all, you may do the following two things:

-   read the *How to contribute* section below to learn about forking, working and pulling,
-   from your fork of the repository, switch to the `dev` branch: this is where the dev things are done.

### How to contribute ?

If you want to correct a typo or update a feature of Bash-Utils, the first thing to do is
[create your own fork of the repository](http://help.github.com/articles/fork-a-repo).
You will need a (free) GitHub account to do this and your copy will appear in your forks list.
This is on THIS repository (your own fork) that you will work (you have no right to make 
direct `push` on the original repository).

Once your work seems finished, you'll have to commit it and push it on your fork (you may 
finally see your modifications on the sources view on GitHub). Then you'll have to make a 
"pull-request" to the original repository, commenting it with a description of your correction or
update, or anything you want me to know about ... Then, if your work seems ok for me 
(and it certainly will :) and when I'll have the time (!), your work will finally be 
"merged" in the original repository and you will be able to (eventually) close your fork. 
Note that the "merge" of a pull-request keeps your name and profile as the "commiter" 
(the one who made the stuff).

**BEFORE** you start a work on the code, please check that this has NOT been done yet, or part
of it, by giving a look at <http://github.com/piwi/markdown-extended/pulls>. If you 
find a pull-request that seems to be like the modification you were going to do, you can 
comment the request with your vision of the thing or your experience.

### Full installation of a fork

To prepare a development version of Bash-Utils, clone your fork of the repository and
put it on the "dev" branch:

    git clone http://gitlab.com/<your-username>/bash-utils.git
    cd bash-utils
    git checkout dev

Then you can create your own branch with the name of your feature:

    git checkout -b <my-branch>

The development process of the package requires some external dependencies to work:

-   *BATS*, a test suite for Bash scripts: <http://github.com/sstephenson/bats>
-   *ShellCheck*, a Bash scripting validator: <http://github.com/koalaman/shellcheck>

Once you have installed them, your clone is ready ;)

You can *synchronize* your fork with current original repository by defining a remote to it
and pulling new commits:

    // create an "upstream" remote to the original repo
    git remote add upstream http://gitlab.com/piwi/bash-utils.git

    // get last original remote commits
    git checkout dev
    git pull upstream dev

### Development life-cycle

As said above, all development MUST be done on the `dev` branch of the repository. Doing so we
can commit our development features to let users using a clone test and improve them.

When the work gets a stable stage, it seems to be time to build and publish a new release. This
is done by creating a tag named like `vX.Y.Z[-status]` from the "master" branch after having
merged the "dev" one in. Please see the [Semantic Versioning](http://semver.org/) work by 
Tom Preston-Werner for more info about the release version name construction rules.

### Create a new module

If you want to create a new module, put your fork on a new `module-NAME` branch and develop your
module in the `libexec/bash-utils-modules/` directory using the Bash-Utils internal model. Then create
a unit-test file to test your module's features in a `test/module-NAME.bats` file.

How-tos
-------

The `make.sh` script distributed with the sources embeds all required utilities to build, test and document
the package.

### Generate the man-pages

To automatically re-generate the manpages of the package, you can use:

    $ ./make.sh manpages

To generate them manually, you can run:

    $ bin/markdown-extended -f man -o man/bash-utils.1.man man/MANPAGE.1.md
    $ man man/bash-utils.1.man
    $ bin/markdown-extended -f man -o man/bash-utils.1.man man/MANPAGE.7.md
    $ man man/bash-utils.7.man

### Launch unit-tests

The unit-testing of the app is handled with [BATS](http://github.com/sstephenson/bats).

You can verify that your package passes all tests running:

    $ ./make.sh test

All tests are stored in the `test/` directory of the package and
are *Bats* scripts. See the documentation of Bats for more info.

To test the lib manually, you can run:

    bats test/*.bats

### Check coding standards errors

You can check the code common errors using [ShellCheck](http://github.com/koalaman/shellcheck)
by running:

    $ ./make.sh validate

The default behavior of such a validation will ignore the following rules:

-   **SC2034**: unused variables ; because of the library structure
-   **SC2016**: single quotes not expanded ; because of the error usage of functions

You can check the lib manually running:

    shellcheck --shell=bash --exclude=SC2034,SC2016 libexec/*

### Make a new release

To make a new release of the package, you must follow these steps:

1.  merge the "dev" branch into "master"

        git checkout master
        git merge --no-ff --no-commit dev

2.  validate unit-tests:

        ./make.sh test

3.  bump new version number and commit:

        ./make.sh version X.Y.Z-STATE

4.  update the changelog ; you can use <https://github.com/atelierspierrot/atelierspierrot/blob/master/console/git-changelog.sh>.

5.  commit changes:

        git commit -a -m "preparing release X.Y.Z-STATE"

6.  create the release tag and publish it:

        git tag -a vX.Y.Z-STATE -m "new release ..."
        git push origin vX.Y.Z-STATE

Finally, don't forget to push all changes to `origin` and to make a release page
on GitHub's repository. The best practice is to attach the PHAR archive to the release.

Coding rules
------------

You can inspire yourself from <http://wiki.bash-hackers.org/scripting/style>.

Keep in mind the followings:

-   use space (no tab) ; 1 tab = 4 spaces
-   comment your work (just enough)
-   in case of error, ALWAYS use the `die()` or `error()` functions with a message


----

If you have questions, you can (eventually) contact me at *me [at] e [dash] piwi [dot] fr*.