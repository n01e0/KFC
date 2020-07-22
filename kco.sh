#!/bin/bash
declare -a version=(echo $1|grep -oP '[0-9]\.[0-9]+')
declare -a commit_count=(echo $1|python3 -c "print(input().split('.')[2].split('-')[1]))
declare -a versions_hash=(git log --pretty=format:"%h %d"|grep "${version})")
