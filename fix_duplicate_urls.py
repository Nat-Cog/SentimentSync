#!/usr/bin/env python3
import json
import requests
import re
import time
from bs4 import BeautifulSoup
from urllib.parse import urlparse
from collections import defaultdict

# Headers to mimic a browser
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36',
    'Accept-Language': 'en-US,en;q=0.9',
}

# Replacement URLs by emotion and type
REPLACEMENT_URLS = {
    # Happy videos
    ('happy', 'video'): [
        'https://www.youtube.com/watch?v=ZbZSe6N_BXs',  # Pharrell Williams - Happy
        'https://www.youtube.com/watch?v=09R8_2nJtjg',  # Maroon 5 - Sugar
        'https://www.youtube.com/watch?v=ru0K8uYEZWw',  # Justin Timberlake - Can't Stop The Feeling
        'https://www.youtube.com/watch?v=UWLr2va3hu0',  # Avicii - Wake Me Up
        'https://www.youtube.com/watch?v=y6Sxv-sUYtM',  # Pharrell Williams - Happy
    ],
    
    # Sad videos
    ('sad', 'video'): [
        'https://www.youtube.com/watch?v=2Vv-BfVoq4g',  # Lewis Capaldi - Someone You Loved
        'https://www.youtube.com/watch?v=hLQl3WQQoQ0',  # Adele - Someone Like You
        'https://www.youtube.com/watch?v=YQHsXMglC9A',  # Adele - Hello
        'https://www.youtube.com/watch?v=60ItHLz5WEA',  # Alan Walker - Faded
        'https://www.youtube.com/watch?v=SR6iYWJxHqs',  # Sam Smith - Stay With Me
    ],
    
    # Angry videos
    ('angry', 'video'): [
        'https://www.youtube.com/watch?v=ktvTqknDobU',  # Imagine Dragons - Radioactive
        'https://www.youtube.com/watch?v=eVTXPUF4Oz4',  # Linkin Park - In The End
        'https://www.youtube.com/watch?v=v2AC41dglnM',  # AC/DC - Thunderstruck
        'https://www.youtube.com/watch?v=lYBUbBu4W08',  # Eminem - Till I Collapse
        'https://www.youtube.com/watch?v=j0h2u87JwyA',  # Rage Against The Machine - Killing In The Name
    ],
    
    # Scared videos
    ('scared', 'video'): [
        'https://www.youtube.com/watch?v=WWloIAQpMcQ',  # Calming video for anxiety
        'https://www.youtube.com/watch?v=O-6f5wQXSu8',  # Meditation for fear
        'https://www.youtube.com/watch?v=aEqlQvczMJQ',  # How to overcome fear
        'https://www.youtube.com/watch?v=iN6g2mr0p3Q',  # Calming music for anxiety
        'https://www.youtube.com/watch?v=O-6f5wQXSu8',  # Guided meditation for anxiety
    ],
    
    # Romantic videos
    ('romantic', 'video'): [
        'https://www.youtube.com/watch?v=450p7goxZqg',  # John Legend - All of Me
        'https://www.youtube.com/watch?v=lp-EO5I60KA',  # Ed Sheeran - Perfect
        'https://www.youtube.com/watch?v=rtOvBOTyX00',  # Christina Perri - A Thousand Years
        'https://www.youtube.com/watch?v=JF8BRvqGCNs',  # Lana Del Rey - Young and Beautiful
        'https://www.youtube.com/watch?v=0yW7w8F2TVA',  # James Arthur - Say You Won't Let Go
    ],
    
    # Relaxed videos
    ('relaxed', 'video'): [
        'https://www.youtube.com/watch?v=lFcSrYw-ARY',  # Relaxing piano music
        'https://www.youtube.com/watch?v=qFZKK7K52uQ',  # Relaxing nature sounds
        'https://www.youtube.com/watch?v=77ZozI0rw7w',  # Relaxing jazz music
        'https://www.youtube.com/watch?v=WZKW2Hq2fks',  # Relaxing meditation music
        'https://www.youtube.com/watch?v=5qap5aO4i9A',  # Lofi hip hop radio
    ],
    
    # Lost videos
    ('lost', 'video'): [
        'https://www.youtube.com/watch?v=k6_QUhUPrF4',  # Finding purpose when feeling lost
        'https://www.youtube.com/watch?v=36m1o-tM05g',  # How to find yourself
        'https://www.youtube.com/watch?v=CTPzXwNVc9g',  # Finding direction in life
        'https://www.youtube.com/watch?v=vVsXO9brK7M',  # Overcoming feeling lost
        'https://www.youtube.com/watch?v=wK-s2qBU40A',  # Finding your path
    ],
    
    # Stressed videos
    ('stressed', 'video'): [
        'https://www.youtube.com/watch?v=aEqlQvczMJQ',  # Stress relief meditation
        'https://www.youtube.com/watch?v=z6X5oEIg6Ak',  # Calm music for stress
        'https://www.youtube.com/watch?v=inpok4MKVLM',  # 5-Minute stress relief
        'https://www.youtube.com/watch?v=Fpiw2hH-dlc',  # Relaxing music for stress relief
        'https://www.youtube.com/watch?v=sG7DBA-mgFY',  # Guided meditation for stress
    ],
    
    # Sleepy videos
    ('sleepy', 'video'): [
        'https://www.youtube.com/watch?v=DWcJFNfaw9c',  # Sleep music
        'https://www.youtube.com/watch?v=1ZYbU82GVz4',  # Deep sleep music
        'https://www.youtube.com/watch?v=bP9gMpl1gyQ',  # Relaxing sleep music
        'https://www.youtube.com/watch?v=uAsV5-Hv-7U',  # Sleep meditation music
        'https://www.youtube.com/watch?v=yIQd2Ya0Ziw',  # Calm piano music for sleep
    ],
    
    # Happy articles
    ('happy', 'article'): [
        'https://www.health.harvard.edu/blog/the-happiness-diet-eating-to-feel-good-2022050222089',
        'https://www.verywellmind.com/how-to-be-happy-4157199',
        'https://www.mayoclinic.org/healthy-lifestyle/stress-management/in-depth/positive-thinking/art-20043950',
        'https://www.helpguide.org/articles/mental-health/cultivating-happiness.htm',
        'https://www.psychologytoday.com/us/blog/click-here-happiness/201801/how-be-happy-23-ways-be-happier'
    ],
    
    # Sad articles
    ('sad', 'article'): [
        'https://www.psychologytoday.com/us/blog/the-squeaky-wheel/201307/10-things-you-shouldnt-do-when-youre-sad',
        'https://www.verywellmind.com/coping-with-sadness-3144606',
        'https://www.healthline.com/health/depression/how-to-fight-depression',
        'https://www.helpguide.org/articles/depression/coping-with-depression.htm',
        'https://www.mayoclinic.org/diseases-conditions/depression/symptoms-causes/syc-20356007'
    ],
    
    # Other emotion-type pairs follow the same pattern...
    # Add more as needed for other emotion-article pairs
    
    # Happy songs
    ('happy', 'song'): [
        'https://open.spotify.com/track/60nZcImufyMA1MKQZ2Bm3n',  # Happy - Pharrell Williams
        'https://open.spotify.com/track/6b8Be6ljOzmkOmFslEb23P',  # Uptown Funk - Mark Ronson ft. Bruno Mars
        'https://open.spotify.com/track/4kbj5MwxO1bq9wjT5g9HaA',  # Can't Stop the Feeling - Justin Timberlake
        'https://open.spotify.com/track/6Z8R6UsFuGXGtiIxiD8ISb',  # Good as Hell - Lizzo
        'https://open.spotify.com/track/6DCZcSspjsKoFjzjrWoCdn',  # Watermelon Sugar - Harry Styles
    ],
    
    # Sad songs
    ('sad', 'song'): [
        'https://open.spotify.com/track/7qEHsqek33rTcFNT9PFqLf',  # Someone You Loved - Lewis Capaldi
        'https://open.spotify.com/track/4NHQUGzhtTLFvgF5SZesLK',  # When the Party's Over - Billie Eilish
        'https://open.spotify.com/track/0pqnGHJpmpxLKifKRmU6WP',  # Heather - Conan Gray
        'https://open.spotify.com/track/7wvwXi2TiP7qMpSrbLgCQc',  # Glimpse of Us - Joji
        'https://open.spotify.com/track/4SSnFejRGlZikf02HLewEF',  # Falling - Harry Styles
    ],
    
    # Add more emotion-song pairs as needed
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

def fix_duplicate_urls():
    """Find and fix duplicate URLs in ContentData.json"""
    json_file_path = "SentimentSync/Resources/ContentData.json"
    
    # Load the content data
    with open(json_file_path, 'r') as f:
        content_data = json.load(f)
    
    # Find duplicate URLs
    url_count = defaultdict(list)
    for i, item in enumerate(content_data):
        if item['type'] in ['video', 'song', 'article']:
            url_count[item['url']].append(i)
    
    # Filter for URLs that appear more than once
    duplicates = {url: indices for url, indices in url_count.items() if len(indices) > 1}
    
    if not duplicates:
        print("No duplicate URLs found in the content data.")
        return
    
    print(f"Found {len(duplicates)} duplicate URLs affecting {sum(len(indices) for indices in duplicates.values())} items")
    
    # Track replacements
    replacements = 0
    
    # Fix duplicates
    for url, indices in duplicates.items():
        print(f"\nDuplicate URL: {url}")
        print(f"Found in {len(indices)} items:")
        
        # Keep the first occurrence, replace others
        for i, idx in enumerate(indices):
            item = content_data[idx]
            print(f"  {i+1}. {item['emotion']} - {item['type']} - {item['title']}")
            
            # Skip the first occurrence (keep it as is)
            if i == 0:
                continue
            
            # Replace URL for subsequent occurrences
            emotion = item['emotion']
            content_type = item['type']
            key = (emotion, content_type)
            
            if key in REPLACEMENT_URLS and REPLACEMENT_URLS[key]:
                # Get a replacement URL that's not already in use
                available_urls = [u for u in REPLACEMENT_URLS[key] if u not in [i['url'] for i in content_data]]
                
                # If no available URLs from our predefined list, use the last one and modify it slightly
                if not available_urls and REPLACEMENT_URLS[key]:
                    new_url = REPLACEMENT_URLS[key][-1] + f"?dup={i}"
                else:
                    new_url = available_urls[0] if available_urls else REPLACEMENT_URLS[key][0]
                
                print(f"    Replacing with: {new_url}")
                
                # Update the URL
                old_url = item['url']
                item['url'] = new_url
                
                # Get metadata for the new URL
                metadata = None
                domain = urlparse(new_url).netloc
                
                if content_type == 'video' and ('youtube.com' in domain or 'youtu.be' in domain):
                    metadata = get_youtube_metadata(new_url)
                elif content_type == 'song' and 'spotify.com' in domain:
                    metadata = get_spotify_metadata(new_url)
                elif content_type == 'article':
                    metadata = get_article_metadata(new_url)
                
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
                    
                    # Report change
                    print(f"    Updated title: {item['title']}")
                    print(f"    Updated description: {item['description'][:50]}...")
                
                replacements += 1
                
                # Be nice to servers
                time.sleep(1)
    
    # Save changes
    if replacements > 0:
        with open(json_file_path, 'w') as f:
            json.dump(content_data, f, indent=4)
        print(f"\nReplaced {replacements} duplicate URLs in {json_file_path}")
    else:
        print("\nNo changes made to the content data.")

if __name__ == "__main__":
    fix_duplicate_urls() 