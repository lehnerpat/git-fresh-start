#!/usr/bin/env bash
#
# git-fresh-start - Restart all the branches in your Git repo
#
# Copyright (C) 2013  Nevik Rehnel
#
#############################################################################
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
#
#   Originally developed in answer to this question:
#   http://stackoverflow.com/q/16067475/1761499
#

COMMON_ROOT=0
TEMP_ROOT_BRANCH="NEW_ROOT_COMMIT"

if [ "$1" == "-r" ]; then
    COMMON_ROOT=1
    shift 1
fi

if [ "$#" -eq 1 ]; then
    cd "$1"
fi

orig_branch=$(git symbolic-ref HEAD 2>/dev/null | sed "s@^refs/heads/@@")

if [ "$COMMON_ROOT" -eq 1 ]; then
    echo "Creating new (empty) common root commit"
    git checkout --orphan "$TEMP_ROOT_BRANCH" 2> /dev/null
    git rm -r --cached . >/dev/null
    git clean -dfx > /dev/null
    git commit --allow-empty -m "Initial commit" > /dev/null
fi

git for-each-ref "--format=%(refname)" refs/heads | sed "s@^refs/heads/@@" | while read branch; do
    echo "Transplanting branch $branch"
    newbranch="${branch}_new"
    if [ "$COMMON_ROOT" -eq 1 ]; then
        git checkout -b "$newbranch" "$TEMP_ROOT_BRANCH" > /dev/null 2>/dev/null
        git checkout "$branch" -- . > /dev/null 2>/dev/null
    else
        git checkout "$branch" > /dev/null 2>/dev/null
        git checkout --orphan "$newbranch" > /dev/null 2>/dev/null
    fi
    git commit -C "$branch" > /dev/null
    git branch -D "$branch" > /dev/null
    git branch -m "$newbranch" "$branch" > /dev/null
done

if [ "$COMMON_ROOT" -eq 1 ]; then
    git branch -D "$TEMP_ROOT_BRANCH" > /dev/null
fi

if [ -n "$orig_branch" ]; then
    git checkout "$orig_branch" 2>/dev/null
fi
