#!/bin/sh

if [ ! -f magic ]
then
    echo keesj > magic
    git add magic
    git commit -m magic
else
    cat magic | sha256sum > magic
    git add magic
    COUNT= `git log --oneline | wc -l`
    git commit -m "dev:Commit $COUNT"
fi
