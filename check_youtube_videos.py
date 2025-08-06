#!/usr/bin/env python3
import json
import requests
import re
import time

def get_youtube_video_id(url):
    """Extract YouTube video ID from URL"""
    # Match YouTube URL patterns
    patterns = [
        r'(?:youtube\.com\/watch\?v=|youtu.be\/|youtube\.com\/embed\/|youtube\.com\/v\/)([^&\?\/]+)',
        r'(?:youtube\.com\/watch.*v=)([^&\?\/]+)',
        r'(?:youtu\.be\/)([^&\?\/]+)'
    ]
    
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None

def check_youtube_video(video_id):
    """Check if YouTube video is available"""
    # Use YouTube oEmbed endpoint to check video
    url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
    headers = {'User-Agent': 'Mozilla/5.0 (compatible; VideoChecker/1.0)'}
    
    try:
        response = requests.head(url, timeout=10, headers=headers)
        return response.status_code == 200
    except Exception as e:
        print(f"Error checking video {video_id}: {e}")
        return False

def get_replacement_videos():
    """Return a dictionary of replacement videos by emotion"""
    return {
        "happy": [
            {
                "id": "ZbZSe6N_BXs",
                "title": "Pharrell Williams - Happy",
                "description": "Upbeat song to match your happy mood"
            },
            {
                "id": "Y66j_BUCBMY",
                "title": "Can't Stop the Feeling - Justin Timberlake",
                "description": "Fun and energetic song to boost your happy mood"
            },
            {
                "id": "ru0K8uYEZWw",
                "title": "Good Vibes Only - Happy Music Mix",
                "description": "A happy music compilation to brighten your day"
            }
        ],
        "sad": [
            {
                "id": "2Vv-BfVoq4g",
                "title": "Lewis Capaldi - Someone You Loved",
                "description": "Emotional ballad that resonates with sadness"
            },
            {
                "id": "hLQl3WQQoQ0",
                "title": "Adele - Someone Like You",
                "description": "A moving song about love and loss"
            },
            {
                "id": "60ItHLz5WEA",
                "title": "Alan Walker - Faded",
                "description": "Melancholic electronic music with emotional lyrics"
            }
        ],
        "angry": [
            {
                "id": "5abamRO41fE",
                "title": "Anger Management: Breathing Exercise",
                "description": "Guided breathing technique to manage anger"
            },
            {
                "id": "3L4YrGaR8E4",
                "title": "Rage Against The Machine - Bulls On Parade",
                "description": "Powerful song to channel your angry energy"
            },
            {
                "id": "YV4oYkIeGJc",
                "title": "Linkin Park - Numb",
                "description": "Intense music that resonates with feelings of anger"
            }
        ],
        "scared": [
            {
                "id": "WWloIAQpMcQ",
                "title": "Calming Anxiety Relief",
                "description": "Guided meditation to help with fear and anxiety"
            },
            {
                "id": "O-6f5wQXSu8",
                "title": "Guided Meditation for Fear & Anxiety",
                "description": "Relaxation techniques to overcome feelings of fear"
            },
            {
                "id": "lFcSrYw-ARY",
                "title": "Overcoming Fear - Motivational Video",
                "description": "Inspirational talk about facing your fears"
            }
        ],
        "romantic": [
            {
                "id": "lJJT00wqlOo",
                "title": "Ed Sheeran - Perfect",
                "description": "Beautiful love song for romantic moments"
            },
            {
                "id": "450p7goxZqg",
                "title": "John Legend - All of Me",
                "description": "Heartfelt ballad about true love"
            },
            {
                "id": "rtOvBOTyX00",
                "title": "Elvis Presley - Can't Help Falling In Love",
                "description": "Classic romantic song that stands the test of time"
            }
        ],
        "relaxed": [
            {
                "id": "uCD-qMfBWDM",
                "title": "Relaxing Ocean Waves",
                "description": "Peaceful ocean sounds to help you unwind"
            },
            {
                "id": "77ZozI0rw7w",
                "title": "Calming Piano Music",
                "description": "Gentle instrumental music for relaxation"
            },
            {
                "id": "lE6RYpe9FSg",
                "title": "Ambient Music for Deep Relaxation",
                "description": "Soothing sounds to help you find peace and calm"
            }
        ],
        "lost": [
            {
                "id": "QkrJWE1uG-c",
                "title": "Finding Your Purpose - Motivational",
                "description": "Inspirational video about finding your way in life"
            },
            {
                "id": "p4XTMvagCKI",
                "title": "How To Find Yourself When You're Feeling Lost",
                "description": "Practical guidance for times of uncertainty"
            },
            {
                "id": "36m1o-tM05g",
                "title": "Finding Direction When You Feel Lost",
                "description": "Helpful advice for navigating life's crossroads"
            }
        ],
        "stressed": [
            {
                "id": "O-6f5wQXSu8",
                "title": "10-Minute Meditation For Stress",
                "description": "Quick guided meditation to reduce stress"
            },
            {
                "id": "Wd_Yzj-nIYk",
                "title": "Stress Relief Breathing Techniques",
                "description": "Simple exercises to calm your mind and body"
            },
            {
                "id": "sG7DBA-mgFY",
                "title": "Nature Sounds for Stress Relief",
                "description": "Relaxing natural soundscapes to ease tension"
            }
        ],
        "sleepy": [
            {
                "id": "qYnA9wWFHLI",
                "title": "8 Hour Sleep Music",
                "description": "Soothing sounds to help you fall asleep"
            },
            {
                "id": "1ZYbU82GVz4",
                "title": "Rain Sounds for Sleeping",
                "description": "Gentle rain ambience to help you drift off"
            },
            {
                "id": "DGQwd1_dpuc",
                "title": "Deep Sleep Music with Delta Waves",
                "description": "Sleep-inducing music designed to improve sleep quality"
            }
        ]
    }

def update_content_data():
    """Check and update YouTube video links in ContentData.json"""
    # Load the content data
    json_file_path = "SentimentSync/Resources/ContentData.json"
    with open(json_file_path, 'r') as f:
        content_data = json.load(f)
    
    # Get replacement videos
    replacement_videos = get_replacement_videos()
    
    # Track changes
    updates_made = 0
    checked_count = 0
    
    # Filter for video items
    video_items = [item for item in content_data if item['type'] == 'video']
    total_videos = len(video_items)
    
    print(f"Checking {total_videos} YouTube videos...")
    
    # Check each video
    for item in video_items:
        emotion = item['emotion']
        url = item['url']
        video_id = get_youtube_video_id(url)
        
        checked_count += 1
        if checked_count % 5 == 0:
            print(f"Progress: {checked_count}/{total_videos} videos checked")
        
        if not video_id or not check_youtube_video(video_id):
            # Video not available, replace it
            if emotion in replacement_videos and replacement_videos[emotion]:
                # Get a replacement (use index based on the hash of the original URL for consistency)
                replacements = replacement_videos[emotion]
                replacement = replacements[hash(url) % len(replacements)]
                
                # Update the item
                old_url = item['url']
                old_title = item['title']
                
                item['url'] = f"https://www.youtube.com/watch?v={replacement['id']}"
                item['title'] = replacement['title']
                item['description'] = replacement['description']
                
                print(f"\nReplaced: {old_title}")
                print(f"  Old URL: {old_url}")
                print(f"  New URL: {item['url']}")
                print(f"  New Title: {item['title']}")
                
                updates_made += 1
            else:
                print(f"Warning: No replacement found for {emotion} video: {item['title']}")
        
        # Be nice to YouTube's servers
        time.sleep(0.5)
    
    # Save updated data if changes were made
    if updates_made > 0:
        with open(json_file_path, 'w') as f:
            json.dump(content_data, f, indent=4)
        print(f"\nUpdated {updates_made} video items in {json_file_path}")
    else:
        print("\nAll YouTube videos are working correctly!")

if __name__ == "__main__":
    update_content_data() 