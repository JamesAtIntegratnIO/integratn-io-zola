---
title: "My Git Worktree Workflow"
date: 2021-07-21T20:29:02-06:00
aliases:
  - posts/my-git-worktree-workflow/
taxonomies:
  tags: [git, developer, workflow]
  categories: [workflow, dev-life]
syndication:
  - name: dev.to
    url: https://dev.to/jamesatintegratnio/my-git-worktree-workflow-186f
  - name: twitter
    url: https://twitter.com/james_dreier/status/1419403046854045706?s=20
  - name: linkedin
    url: https://www.linkedin.com/posts/jjdreier_my-git-worktree-workflow-activity-6823824959446552576-niGQ
nocomment: false
draft: false
---

I recently made a change to how I work on repositories when I have to work with others. It has been a life saver. 
<!--more-->
There is a TLDR example at the bottom to get you interested in the rest of the article.


## Pain Points
Lets start with the normal git workflow and the pain points it causes. First you clone the repo. You create your branch and you start coding away. Then your buddy hits you up on Slack with a huge PR and scrolling the diff in Github isn't enough for you to approve it. Great. Now you have to stash the code you are working on, update your base so that you have their branch, and pull it all down. Now you can finally review the PR. This is nuts. Its annoying and you completely lose track of whatever you were just working on. I didn't even cover getting back to your branch and getting going again.

## Painting a Picture With a Dev Story
As a developer I want to be able to review my teammates code without having to stash my work or maintain a second copy of the entire repository. I also want to be able to pause my work and work on a different branch again without having to stash my work or maintain a second copy.

<!--adsense-->

## Enter Git Worktree
First off, here is a link to the git worktree [documentation](https://git-scm.com/docs/git-worktree). I won't cover every caveat. So check it out for a lot more info.

Git is capable of maintaining multiple working trees of a single repo. You heard that right. With git worktree you can check out more than one branch at a time and sensibly maintain each of those branches.

I had to rethink my folder folder structure when I started using worktree. It was weird at first. But its been amazing after I settled in.

When I clone a repository with worktree in mind I will do it a little differently.
```bash
$ git clone git@github.com:googleapis/python-tasks.git python-tasks/main
```
This is where the main branch lives. I really don't touch it except to fetch/pull and create new branches with worktree. Its my clean source of truth and I like to keep it that way.

From here I will create a new branch to for whatever I'm working on But I won't use `git branch ${branchName}` or `git checkout -b ${branchName}`. I'll do it with worktree while i'm in the main branch folder.

```bash
$ git worktree add -b my-awesome-branch ../my-awesome-branch main
```
Pay attention to that `../` If you forget it you will end up putting the branch in the folder where main lives and that can get real ugly, real fast. 

So now we have:

```bash
~/Projects
  /python-tasks
    /main
    /my-awesome-branch
```
You can now list all of your working trees with the list argument.
```bash
$ git worktree list
~/Projects/python-tasks/main                63df2ef [master]
~/Projects/python-tasks/my-awesome-branch   63df2ef [my-awesome-branch]
```

I change to that directory. I do my work. Next thing I know I get a message from a teammate and he needs me to do that PR review we've been talking about. With git worktree its too easy. I just go back to main and add his branch to my worktree. 

```bash
$ git worktree add --track -b add-appengine-flexible-tasks-samples ../ppr-review origin/add-appengine-flexible-tasks-samples

Preparing worktree (new branch 'add-appengine-flexible-tasks-samples')
Branch 'add-appengine-flexible-tasks-samples' set up to track remote branch 'add-appengine-flexible-tasks-samples'  from 'origin'.
HEAD is now at e2c8eee chore: generate noxfile.py for samples
```
There is a lot going on in that command. So check out the [doc](https://git-scm.com/docs/git-worktree#Documentation/git-worktree.txt-addltpathgtltcommit-ishgt) for the full explanation, but I'll try to break it down.

`git worktree add`: We've seen this. Its the base command to create a branch and a working tree

`--track`: This sets up tracking mode. We need it to track a remote branch

`-b`: This will create a new branch and we give it the same name as the remote branch because its the right thing to do. But really we could call it anything.

`../pr-review` The path we want it checked out to. Don't forget that `../` 

`origin/add-appengine-flexible-tasks-samples` Finally the `<remote>/<branch>` that we want check out.

Now if we do `git worktree list` We'll see our friends branch in our working tree ready for review.

```bash
$ git worktree list
~/Projects/python-tasks/main                63df2ef [master]
~/Projects/python-tasks/my-awesome-branch   63df2ef [my-awesome-branch]
~/Projects/python-tasks/pr-review           e2c8eee [add-appengine-flexible-tasks-samples]
```
Pretty sweet.

Now I've finished my PR review and I don't need the code anymore. so all we have to do from `main` is
```bash
$ git worktree remove pr-review
```
Poof, The folder is gone and we don't have to clog our working tree up with it anymore. Sometimes we get lazy right? maybe I did `rm -rf ./pr-review`. This is bad. I just broke my working tree. The folders gone but git still knows about it when I do `git worktree list` How can we fix this? Is it time to just throw the whole repo away and clone again? What do we do?

From main as usual:
```bash
$ git worktree prune
```
And now our mistake has been removed from the git and we can continue on about our day.

There are a few other worktree commands out there. Checkout [lock](https://git-scm.com/docs/git-worktree#Documentation/git-worktree.txt-lock) and [unlock](https://git-scm.com/docs/git-worktree#Documentation/git-worktree.txt-unlock) if you need to put a working tree on a thumb drive or a network share thats not always mounted. That will protect it from [prune](https://git-scm.com/docs/git-worktree#Documentation/git-worktree.txt-prune). This was a long one. If you stuck around and found it useful, feel free to hit me up on my socials to tell me about it or teach me a new trick you found thats even better.

## TLDR Example
```bash
$ git worktree add -b emergency-fix ../temp main
$ pushd ../temp
# ... hack hack hack ...
$ git commit -a -m 'emergency fix for boss'
$ popd
$ git worktree remove ../temp
```