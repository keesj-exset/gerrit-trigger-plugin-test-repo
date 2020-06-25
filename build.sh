#!/bin/bash

#
# emulate a longer build to test canceling jobs
#
function tralala()
{
    echo "That's it i quit"
    exit 3
}

trap tralala SIGINT
for i in checkout refresh build sync sign release
do
    for f in `seq 1 10`
    do
        echo "** $i ... step $f **"
        sleep 1
    done
done
exit 0
