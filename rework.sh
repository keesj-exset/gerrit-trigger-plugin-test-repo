#!/bin/sh
#
# Rework a commit (as to create a new patchset with the same commit id
# For gerrit/jenkins this can mean aborting the current job to start a new
# one to build the latested release
#
if [ ! -f magic ]
then
    echo keesj > magic
    git add magic
    git commit -m magic
else
    sha256sum magic > l
    cp l magic
    rm l
    git add magic
    COUNT=`git log --oneline | wc -l`
    git commit --amend --no-edit
    git push origin HEAD:refs/for/master
fi
