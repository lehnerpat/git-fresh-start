git-fresh-start
===============

Restart all the branches in your Git repo

## What does it do?

This script's main task is to transplant currently existing branches, by simply
using their latest commit.

If you choose, a new empty root commit is created, and all branches are created
as direct descendants of that root commit. Otherwise every new branch will have
its own root (they'll be orphan branches) and contain exactly one commit each.
