#!/usr/bin/env python3
import json
import requests
import re
import time
from bs4 import BeautifulSoup
from urllib.parse import urlparse

# Headers to mimic a browser
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36',
    'Accept-Language': 'en-US,en;q=0.9',
}

def get_youtube_metadata(url):
    """Extract metadata from a YouTube URL"""
    try:
        video_id = re.search(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*', url).group(1)
        # Use YouTube oEmbed API to get video metadata
        oembed_url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
        response = requests.get(oembed_url, headers=HEADERS, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            return {
                'title': data.get('title', ''),
                'author': data.get('author_name', '')
            }
    except Exception as e:
        print(f"Error getting YouTube metadata for {url}: {e}")
    
    return None

def get_spotify_metadata(url):
    """Extract metadata from a Spotify URL"""
    # Extract track ID from URL
    try:
        track_id = url.split('/')[-1].split('?')[0]
        
        # Since we can't use Spotify API directly without authentication,
        # we'll try to scrape the title from the OG metadata on the page
        response = requests.get(url, headers=HEADERS, timeout=10)
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            title = soup.find('meta', property='og:title')
            description = soup.find('meta', property='og:description')
            
            if title:
                title_text = title.get('content', '')
                description_text = description.get('content', '') if description else ''
                
                # Parse artist from description if available
                artist = ''
                if description_text and '·' in description_text:
                    artist = description_text.split('·')[0].strip()
                
                return {
                    'title': title_text,
                    'artist': artist
                }
    except Exception as e:
        print(f"Error getting Spotify metadata for {url}: {e}")
    
    return None

def get_article_metadata(url):
    """Extract metadata from an article URL"""
    try:
        response = requests.get(url, headers=HEADERS, timeout=15)
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Try to get title from various common elements
            title = None
            for selector in ['h1', 'meta[property="og:title"]', 'title']:
                if not title:
                    if selector.startswith('meta'):
                        meta_tag = soup.select_one(selector)
                        if meta_tag:
                            title = meta_tag.get('content')
                    else:
                        title_tag = soup.select_one(selector)
                        if title_tag:
                            title = title_tag.text.strip()
            
            # Try to get description from meta tags
            description = None
            for selector in ['meta[name="description"]', 'meta[property="og:description"]']:
                if not description:
                    meta_tag = soup.select_one(selector)
                    if meta_tag:
                        description = meta_tag.get('content')
            
            # If no description found, try to get first paragraph
            if not description:
                first_p = soup.select_one('article p, .content p, .entry-content p, .post-content p, p')
                if first_p:
                    description = first_p.text.strip()
            
            if title:
                return {
                    'title': title[:100],  # Limit length
                    'description': description[:200] if description else ''  # Limit length
                }
    except Exception as e:
        print(f"Error getting article metadata for {url}: {e}")
    
    return None

def create_emotion_description(metadata, emotion, content_type):
    """Create a description that incorporates the emotion"""
    # Define emotion-specific phrases
    emotion_phrases = {
        "happy": [
            "uplifts your mood",
            "brings joy and positivity",
            "perfect for celebrating happy moments",
            "will make you smile and feel good",
            "enhances your happy feelings"
        ],
        "sad": [
            "resonates with feelings of sadness",
            "helps process emotional moments",
            "provides comfort during difficult times",
            "acknowledges and validates your feelings",
            "offers a thoughtful perspective on sadness"
        ],
        "angry": [
            "helps channel and process anger",
            "provides an outlet for intense emotions",
            "transforms anger into productive energy",
            "helps you understand and manage anger",
            "resonates with powerful emotional release"
        ],
        "scared": [
            "helps overcome feelings of fear",
            "provides comfort during anxious moments",
            "offers perspective on dealing with fear",
            "transforms fear into courage",
            "helps calm your worried mind"
        ],
        "romantic": [
            "captures the essence of love",
            "perfect for romantic moments",
            "celebrates the beauty of connection",
            "resonates with heartfelt emotions",
            "enhances feelings of love and intimacy"
        ],
        "relaxed": [
            "promotes deep relaxation",
            "helps you unwind and de-stress",
            "creates a peaceful atmosphere",
            "soothes your mind and body",
            "perfect for calm, quiet moments"
        ],
        "lost": [
            "helps find direction when feeling lost",
            "offers guidance during uncertain times",
            "provides clarity when you feel adrift",
            "illuminates the path forward",
            "helps reconnect with your purpose"
        ],
        "stressed": [
            "reduces stress and tension",
            "helps manage overwhelming feelings",
            "provides relief from daily pressures",
            "restores balance and calm",
            "supports mental well-being during stressful times"
        ],
        "sleepy": [
            "promotes restful sleep",
            "helps you drift peacefully to sleep",
            "creates the perfect bedtime atmosphere",
            "soothes your mind for better rest",
            "designed to improve sleep quality"
        ]
    }
    
    # Get phrases for the specified emotion
    phrases = emotion_phrases.get(emotion, ["complements your current mood"])
    chosen_phrase = phrases[hash(metadata.get('title', '')) % len(phrases)]
    
    # Create descriptions based on content type
    if content_type == "video":
        title = metadata.get('title', 'Video content')
        author = metadata.get('author', '')
        if author:
            return f"{title} by {author} - This video {chosen_phrase} and is perfect for when you're feeling {emotion}."
        else:
            return f"{title} - This video {chosen_phrase} and is perfect for when you're feeling {emotion}."
    
    elif content_type == "song":
        title = metadata.get('title', 'Music')
        artist = metadata.get('artist', '')
        if artist:
            return f"{title} by {artist} - This song {chosen_phrase} and resonates with your {emotion} mood."
        else:
            return f"{title} - This music {chosen_phrase} and resonates with your {emotion} mood."
    
    elif content_type == "article":
        title = metadata.get('title', 'Article')
        description = metadata.get('description', '')
        if description:
            # Use the first sentence or part of the description
            short_desc = description.split('.')[0]
            return f"{short_desc}. This article {chosen_phrase} when you're feeling {emotion}."
        else:
            return f"An insightful article that {chosen_phrase} when you're feeling {emotion}."
    
    return f"Content that {chosen_phrase} when you're feeling {emotion}."

def update_content_data():
    """Update metadata for items in ContentData.json"""
    json_file_path = "SentimentSync/Resources/ContentData.json"
    
    # Load the content data
    with open(json_file_path, 'r') as f:
        content_data = json.load(f)
    
    total_items = sum(1 for item in content_data if item['type'] in ['video', 'song', 'article'])
    print(f"Checking metadata for {total_items} items (videos, songs, articles)...")
    
    # Track updates
    updates = 0
    checked = 0
    
    # Process each item
    for item in content_data:
        if item['type'] not in ['video', 'song', 'article']:
            continue
        
        checked += 1
        if checked % 5 == 0:
            print(f"Progress: {checked}/{total_items}")
        
        url = item['url']
        content_type = item['type']
        emotion = item['emotion']
        
        # Get metadata based on content type
        metadata = None
        domain = urlparse(url).netloc
        
        if content_type == 'video' and ('youtube.com' in domain or 'youtu.be' in domain):
            metadata = get_youtube_metadata(url)
        elif content_type == 'song' and 'spotify.com' in domain:
            metadata = get_spotify_metadata(url)
        elif content_type == 'article':
            metadata = get_article_metadata(url)
        
        # Update item if metadata was found
        if metadata:
            old_title = item['title']
            old_description = item['description']
            
            # Update title if it's different
            if 'title' in metadata and metadata['title'] and metadata['title'] != old_title:
                item['title'] = metadata['title']
            
            # Create and update description
            new_description = create_emotion_description(metadata, emotion, content_type)
            if new_description and new_description != old_description:
                item['description'] = new_description
            
            # Report change if something was updated
            if item['title'] != old_title or item['description'] != old_description:
                print(f"\nUpdated {content_type} ({emotion}):")
                if item['title'] != old_title:
                    print(f"  Old title: {old_title}")
                    print(f"  New title: {item['title']}")
                if item['description'] != old_description:
                    print(f"  Old description: {old_description}")
                    print(f"  New description: {item['description']}")
                updates += 1
        
        # Be nice to servers
        time.sleep(1)
    
    # Save changes if updates were made
    if updates > 0:
        with open(json_file_path, 'w') as f:
            json.dump(content_data, f, indent=4)
        print(f"\nUpdated metadata for {updates} items in {json_file_path}")
    else:
        print("\nNo metadata updates needed")

if __name__ == "__main__":
    update_content_data() 