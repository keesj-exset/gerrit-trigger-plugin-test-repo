#!/bin/sh
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
    git commit -m "dev:Commit $COUNT"
    git push origin HEAD:refs/for/master
fi
