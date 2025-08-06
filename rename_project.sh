#!/bin/bash

# Rename project from SentimentVibe to SentimentSync

# Create a backup first
mkdir -p ../backup
cp -r . ../backup/SentimentVibe_backup_$(date +%Y%m%d%H%M%S)
echo "Created backup in ../backup/"

# Function to rename files and folders
rename_files_and_folders() {
    echo "Renaming files and folders..."
    
    # Rename directories
    for dir in $(find . -type d -name "*SentimentVibe*" | sort -r); do
        new_dir=$(echo $dir | sed 's/SentimentVibe/SentimentSync/g')
        echo "Renaming directory: $dir -> $new_dir"
        mv "$dir" "$new_dir"
    done
    
    # Rename files
    for file in $(find . -type f -name "*SentimentVibe*" | sort -r); do
        new_file=$(echo $file | sed 's/SentimentVibe/SentimentSync/g')
        echo "Renaming file: $file -> $new_file"
        mkdir -p $(dirname "$new_file")
        mv "$file" "$new_file"
    done
}

# Function to update file contents
update_file_contents() {
    echo "Updating file contents..."
    
    # Update content in all files
    find . -type f -not -path "*/\.*" -not -path "*/build/*" -not -name "rename_project.sh" | xargs grep -l "SentimentVibe" | while read file; do
        echo "Updating content in: $file"
        sed -i '' 's/SentimentVibe/SentimentSync/g' "$file"
    done
}

# Execute the functions
rename_files_and_folders
update_file_contents

echo "Project renamed from SentimentVibe to SentimentSync"
