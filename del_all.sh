#!/bin/bash

GB_LOCAL_REPO=/var/gitbucket/data/repositories
MIRROR_BASE=/var/gitbucket/mirrors
SRC_BASE=${GB_LOCAL_REPO}/
DST_BASE=git@bitbucket.org:
DST_USER=bitbucketuser

function repo_put() {
  curl  -X POST \
    -H "Content-type: application/json" \
    https://api.bitbucket.org/2.0/repositories/${DST_USER}/$1 \
    -d '{"scm":"git", "is_private":true, "fork_policy":"no_forks", "has_wiki":"true" }'
}

function repo_del() {
  curl  -X DELETE \
    https://api.bitbucket.org/2.0/repositories/${DST_USER}/$1 
}

function repo_get() {
  curl  -X GET \
    https://api.bitbucket.org/2.0/repositories/${DST_USER}/$1
}

function repos_delete() {
  echo $1 / $2
  NOFOUND="`repo_get $1__$2 | grep 'Resource not found'`"
  echo NOFOUND=${NOFOUND}
  if [ -z "$NOFOUND" ]
  then
    echo found
    repo_del $1__$2
  else
    echo notfound
  fi
}


LISTS=`find ${GB_LOCAL_REPO} -type d -name '*.git' | grep -v 'wiki.git' | sed "s#$GB_LOCAL_REPO/\(.*\)/\(.*\).git#\1_\2#"`

for item in $LISTS
do
    repos_delete ${item%%_*} ${item#*_}
done

