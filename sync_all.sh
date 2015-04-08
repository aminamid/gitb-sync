#!/bin/bash

GB_LOCAL_REPO=/var/gitbucket/data/repositories
MIRROR_BASE=/var/gitbucket/mirrors
SRC_BASE=${GB_LOCAL_REPO}/
DST_BASE=git@bitbucket.org:
DST_USER=bitbucketuser

function repo_put() {
  export DESTREPO=$(tr '[A-Z]' '[a-z]' <<< $1 )
  curl  -X POST \
    -H "Content-type: application/json" \
    https://api.bitbucket.org/2.0/repositories/${DST_USER}/$DESTREPO \
    -d '{"scm":"git", "is_private":true, "fork_policy":"no_forks", "has_wiki":"true" }'
}

function repo_del() {
  export DESTREPO=$(tr '[A-Z]' '[a-z]' <<< $1 )
  curl  -X DELETE \
    https://api.bitbucket.org/2.0/repositories/${DST_USER}/$DESTREPO 
}

function repo_get() {
  export DESTREPO=$(tr '[A-Z]' '[a-z]' <<< $1 )
  curl  -X GET \
    https://api.bitbucket.org/2.0/repositories/${DST_USER}/$DESTREPO
}

function repos_init() {
  echo $1 / $2
  NOFOUND="`repo_get $1__$2 | grep 'Resource not found'`"
  echo NOFOUND=${NOFOUND}
  if [ -z "$NOFOUND" ]
  then
    echo not err
    cd ${MIRROR_BASE}/${1}/${2}.git
    git fetch --all
    git push origin2 --mirror
    cd ${MIRROR_BASE}/${1}/${2}.wiki.git
    git fetch --all
    git push origin2 --mirror
  else
    echo err
    export DESTREPO=$(tr '[A-Z]' '[a-z]' <<< ${1}__${2} )
    repo_put $1__$2
    cd ${MIRROR_BASE}
    mkdir -p $1
    cd $1
    git clone --mirror ${SRC_BASE}${1}/${2}.git
    cd ${2}.git
    git remote add origin2 ${DST_BASE}${DST_USER}/${DESTREPO}.git
    git push origin2 --mirror
    cd ${MIRROR_BASE}/${1}
    git clone --mirror ${SRC_BASE}${1}/${2}.wiki.git
    cd ${2}.wiki.git
    git remote add origin2 ${DST_BASE}${DST_USER}/${DESTREPO}.git/wiki
    git push origin2 --mirror
    cd ..
  fi
}


LISTS=`find ${GB_LOCAL_REPO} -type d -name '*.git' | grep -v 'wiki.git' | sed "s#$GB_LOCAL_REPO/\(.*\)/\(.*\).git#\1_\2#"`

for item in $LISTS
do
    repos_init ${item%%_*} ${item#*_}
done

