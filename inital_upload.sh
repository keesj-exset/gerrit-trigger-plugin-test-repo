#git init
git remote add origin ssh://admin@localhost:29418/gerrit_test
git push origin master
#git clone ssh://admin@localhost:29418/gerrit_test

gitdir=$(git rev-parse --git-dir); scp -p -P 29418 admin@localhost:hooks/commit-msg ${gitdir}/hooks/
 



