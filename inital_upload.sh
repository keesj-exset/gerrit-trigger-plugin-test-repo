#git init
. ../env.sh
git remote rm origin
git remote add origin ssh://admin@$IP:29418/gerrit_test
git push origin master
#git clone ssh://admin@localhost:29418/gerrit_test

gitdir=$(git rev-parse --git-dir); scp -p -P 29418 admin@$IP:hooks/commit-msg ${gitdir}/hooks/
 



