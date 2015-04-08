Sync all repositories of gitbucket to bitbucket

sync /path/to/gitbucket/user/reponame.git to git@bitbucket.org:bitbucketuser/user__reponame.git
sync /path/to/gitbucket/user/reponame.wiki.git to git@bitbucket.org:bitbucketuser/user__reponame.git/wiki

all uppercase characters in repositories are convert to downcase, because bitbucket doesnt allow uppercase.

# Usage

## Change configurations

Change below params

```
GB_LOCAL_REPO=/var/gitbucket/data/repositories
MIRROR_BASE=/var/gitbucket/mirrors
SRC_BASE=${GB_LOCAL_REPO}/
DST_BASE=git@bitbucket.org:
DST_USER=bitbucketuser
```

* GB_LOCAL_REPO: gitbucket local repositories (to find targets to sync)
* MIRROR_BASE: where to create temporary mirror repositories
* SRC_BASE: to pull from temporary mirrors (like "http://host.com/git/" configuration may work) 
* DST_USER: Your bitbucket user

And also you must configure bitbucket ssh key configurations. 

```
bash -x sync_all
```

may help you debug

## example of clone

```:crontab
5 10-20 * * *       bash -l -c " cd /var/gitbucket/gitb-sync; ./sync_all.sh 2>&1 | logger -t gitbsync -p local0.info "
```

## delete all

delete all repositories on bitbucket.
 
