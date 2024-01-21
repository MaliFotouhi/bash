#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Specify the list of repos
repos=(
    "/path/to/repo1"
    "/path/to/repo2"
    "/path/to/repo3"
    # Add as many repos as you want...
)

# Loop through repo list
for repo_dir in "${repos[@]}"
do
    echo -e "\n" "${YELLOW}#==============================================#${NC}"
    echo "Updating $repo_dir"
    cd $repo_dir

    # Check for modified files that are not yet committed
    git_status=$(git status --porcelain)
    if [[ -n $git_status ]]; then
        echo -e "${RED}Uncommitted changes detected, skipping this repo.${NC}"
        continue
    fi

    # Fetching all branches
    echo "Fetching all branches from the remote..."
    git fetch origin

    # Get the list of all remote branches that were just fetched
    remote_branches=`git branch --remote | grep -v master | sed 's/origin\///'`

    # Loop through the remote branches and update local branches if they exist
    for branch in $remote_branches
    do
        # Check if local branch exists
        if git show-ref --verify --quiet refs/heads/$branch; then
            echo "Merging changes into local branch: $branch"
            git checkout $branch
            git merge origin/$branch
            echo -e "${GREEN}Branch $branch updated successfully.${NC}"
        # else
        #     echo -e "${RED}Local branch $branch doesn't exist. Skipping...${NC}"
        fi
    done

    # Checking out to the master branch
    echo "Merging changes into master branch..."
    if git show-ref --verify --quiet refs/heads/master; then
        git checkout master
        git merge origin/master
        echo -e "${GREEN}Master branch updated successfully.${NC}"
    else
        echo -e "${RED}Master branch not found, remaining on current branch..Will check main!${NC}"
       if git show-ref --verify --quiet refs/heads/main; then
            git checkout main
            git merge origin/main
            echo -e "${GREEN}Main branch updated successfully.${NC}"
        fi
    fi
done