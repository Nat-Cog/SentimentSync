#!/usr/bin/env python3
import json
import uuid
import os

# Load the JSON file
file_path = 'SentimentSync/Resources/ContentData.json'
with open(file_path, 'r') as f:
    data = json.load(f)

# Update all IDs with new UUIDs
for item in data:
    item['id'] = str(uuid.uuid4()).lower()

# Save the updated JSON
with open(file_path, 'w') as f:
    json.dump(data, f, indent=4)

print(f"Updated {len(data)} items with unique UUIDs")
