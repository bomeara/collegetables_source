#!/bin/bash
# Usage: git-add-commit.sh <message>
# From https://gist.github.com/maxrodrigo/b893bf76f68588766d602a57f10c4ff8?permalink_comment_id=4640883#gistcomment-4640883
# ensure any individual file is under 2gb and any file over 300mb is tracked using git-lfs before committing
# Check if a commit message was provided
if [ $# -eq 0 ]; then
  echo "Error: No commit message provided"
  exit 1
fi

# Store the commit message in a variable
message="$1"

# Function to determine the size of a file in KB
function size_in_kb() {
  local file="$1"
  if [ -f "$file" ]; then
    echo $(( $(wc -c < "$file") / 1024 ))))
  else
    echo 0
  fi
}

# Store the sum of sizes of staged files in a variable
git add -N .\/*
staged_files=$(git diff --name-only)

staged_size=0
if [ -n "$staged_files" ]; then
  staged_size=$(git diff --name-only -z | xargs -0 du -kc | tail -n 1 | awk '{print $1}')
else
  staged_size=0
fi
git reset HEAD

COUNTER=1
# Add changes in smaller chunks
while [ "$staged_size" -gt 0 ]; do
  chunk_size=0
  git add -N .\/*
  staged_files=$(git diff --name-only)
  git reset HEAD
  while IFS= read -r file; do
    file_size=$(size_in_kb "$file")
    if [ "$((chunk_size + file_size))" -le 2000000 ]; then
      chunk_size=$((chunk_size + file_size))
      git add "$file"
      #echo "$chunk_size"
    else
      break
    fi
  done <<< "$staged_files"

  echo "About to commit $COUNTER"
  git commit -m "$message (chunk $COUNTER)"
  #echo "$message (chunk $COUNTER)"
  let COUNTER++
  git add -N .\/*
  staged_files=$(git diff --name-only)

  if [ -n "$staged_files" ]; then
    staged_size=$(git diff --name-only -z | xargs -0 du -kc | tail -n 1 | awk '{print $1}')
  else
    echo "No staged files left."
    staged_size=0
  fi
  git reset HEAD
done

