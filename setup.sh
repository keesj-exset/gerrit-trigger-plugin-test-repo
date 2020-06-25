#!/bin/sh
. ../env.sh
#ssh -p 29418 admin@$IP gerrit create-project gerrit_test
#ssh -p 29418 admin@$IP gerrit create-account jenkins --ssh-key -


echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDc6gxocqrN0R+fXkhwvAeDgOFmByRyiQ2RQiKttGyfTl9XdyM2DZwZ1nZvr0hRRpmWb842QHNXS6npVpda1jz9LBe5bbfp0RjdpbaiHwz9qSr9tgyRBAdJVOZcOCfIFEEqnzH+OSkGukt5tA/1DYCu+baf7ngmHKwfdvNV39btlCXOmk57dbzCHrgQ5E3CRQHJkNqcEFbHuVQ7jHajdwDk5zrCMREriHec5WoCkt1f1cHmKF4vwJFvTGIfdPBZq3Ac8AdbA90h4dPDd7Nxasqwq0OnzgGpytXRXFuBeivGcbTTxtnGqPzOXa0NF3xVuPAeiBkQ6SEVfDNPR6hZxG1j jenkins@00fe8ce6e030 |  \
ssh -p 29418 admin@$IP gerrit set-account --add-ssh-key - jenkins


# add jenkins to the non interactive users



