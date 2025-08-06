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

# Replacement article URLs by emotion
REPLACEMENT_URLS = {
    "happy": [
        "https://www.health.harvard.edu/blog/the-happiness-diet-eating-to-feel-good-2022050222089",
        "https://www.verywellmind.com/how-to-be-happy-4157199",
        "https://www.mayoclinic.org/healthy-lifestyle/stress-management/in-depth/positive-thinking/art-20043950",
        "https://www.helpguide.org/articles/mental-health/cultivating-happiness.htm",
        "https://www.psychologytoday.com/us/blog/click-here-happiness/201801/how-be-happy-23-ways-be-happier",
        "https://www.ted.com/talks/dan_gilbert_the_surprising_science_of_happiness",
        "https://greatergood.berkeley.edu/article/item/happy_life_different_from_meaningful_life",
        "https://www.health.harvard.edu/mind-and-mood/the-happiness-diet-eating-to-feel-good",
        "https://www.nytimes.com/guides/well/how-to-be-happy",
        "https://www.healthline.com/health/how-to-be-happy"
    ],
    "sad": [
        "https://www.psychologytoday.com/us/blog/the-squeaky-wheel/201307/10-things-you-shouldnt-do-when-youre-sad",
        "https://www.verywellmind.com/coping-with-sadness-3144606",
        "https://www.healthline.com/health/depression/how-to-fight-depression",
        "https://www.helpguide.org/articles/depression/coping-with-depression.htm",
        "https://www.mayoclinic.org/diseases-conditions/depression/symptoms-causes/syc-20356007",
        "https://www.psychologytoday.com/us/blog/emotional-fitness/201311/10-things-do-when-youre-feeling-sad",
        "https://www.mind.org.uk/information-support/types-of-mental-health-problems/depression/about-depression/",
        "https://www.webmd.com/depression/features/natural-treatments",
        "https://www.nami.org/About-Mental-Illness/Mental-Health-Conditions/Depression"
    ],
    "angry": [
        "https://www.apa.org/topics/anger/control",
        "https://www.mayoclinic.org/healthy-lifestyle/adult-health/in-depth/anger-management/art-20045434",
        "https://www.healthline.com/health/mental-health/how-to-control-anger",
        "https://www.psychologytoday.com/us/basics/anger",
        "https://www.helpguide.org/articles/relationships-communication/anger-management.htm",
        "https://www.verywellmind.com/anger-management-strategies-4178870",
        "https://www.mind.org.uk/information-support/types-of-mental-health-problems/anger/",
        "https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/anger/",
        "https://www.betterhealth.vic.gov.au/health/healthyliving/anger-how-it-affects-people",
        "https://www.goodtherapy.org/learn-about-therapy/issues/anger"
    ],
    "scared": [
        "https://www.verywellmind.com/how-to-cope-with-fear-2671631",
        "https://www.psychologytoday.com/us/blog/the-courage-be-present/201001/how-practice-being-fear",
        "https://www.healthline.com/health/how-to-overcome-fear",
        "https://www.helpguide.org/articles/anxiety/phobias-and-fears.htm",
        "https://www.mind.org.uk/information-support/types-of-mental-health-problems/phobias/about-phobias/",
        "https://www.apa.org/topics/anxiety/panic-disorder",
        "https://www.mayoclinic.org/diseases-conditions/anxiety/symptoms-causes/syc-20350961",
        "https://www.health.harvard.edu/blog/coping-with-coronavirus-anxiety-2020031219183",
        "https://www.webmd.com/anxiety-panic/features/coping-with-anxiety",
        "https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/fear-and-anxiety/"
    ],
    "romantic": [
        "https://www.psychologytoday.com/us/basics/relationships",
        "https://www.helpguide.org/articles/relationships-communication/relationship-help.htm",
        "https://www.gottman.com/blog/category/romance-friendship/",
        "https://www.verywellmind.com/all-about-healthy-relationship-4774802",
        "https://www.psychologytoday.com/us/blog/in-the-name-love/201502/10-ways-express-love",
        "https://www.healthline.com/health/relationships/relationship-advice",
        "https://greatergood.berkeley.edu/topic/love_relationships",
        "https://www.nytimes.com/guides/well/how-to-have-a-better-relationship",
        "https://www.psychologytoday.com/us/blog/in-the-name-love/202002/what-is-romantic-love",
        "https://www.marriage.com/advice/romance/"
    ],
    "relaxed": [
        "https://www.mayoclinic.org/healthy-lifestyle/stress-management/in-depth/relaxation-technique/art-20045368",
        "https://www.healthline.com/health/mental-health/relaxation-techniques",
        "https://www.verywellmind.com/popular-relaxation-techniques-2584192",
        "https://www.health.harvard.edu/mind-and-mood/six-relaxation-techniques-to-reduce-stress",
        "https://www.helpguide.org/articles/stress/relaxation-techniques-for-stress-relief.htm",
        "https://www.psychologytoday.com/us/blog/click-here-happiness/201812/self-care-101-10-ways-take-better-care-yourself",
        "https://www.webmd.com/balance/guide/blissing-out-10-relaxation-techniques-reduce-stress-spot",
        "https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/tips-to-reduce-stress/",
        "https://www.mind.org.uk/information-support/types-of-mental-health-problems/stress/",
        "https://www.apa.org/topics/stress/tips"
    ],
    "lost": [
        "https://tinybuddha.com/blog/feeling-lost-how-to-find-yourself-again/",
        "https://www.psychologytoday.com/us/blog/click-here-happiness/202009/feeling-lost-8-ways-find-yourself-again",
        "https://www.healthline.com/health/mental-health/i-feel-lost",
        "https://www.verywellmind.com/how-to-find-yourself-when-feeling-lost-5193133",
        "https://greatergood.berkeley.edu/article/item/seven_ways_to_find_your_purpose_in_life",
        "https://www.lifehack.org/articles/communication/feeling-lost-life-how-find-yourself-again.html",
        "https://www.forbes.com/sites/womensmedia/2020/02/18/feeling-lost-how-to-find-yourself-and-get-back-on-track/",
        "https://www.mindbodygreen.com/articles/what-to-do-when-you-feel-lost",
        "https://medium.com/mind-cafe/feeling-lost-in-life-heres-how-to-find-your-way-again-e936bbe854fa",
        "https://www.psychologytoday.com/us/blog/the-gen-y-psy/201810/finding-yourself-in-the-age-identity"
    ],
    "stressed": [
        "https://www.mayoclinic.org/healthy-lifestyle/stress-management/in-depth/stress-relievers/art-20047257",
        "https://www.verywellmind.com/tips-to-reduce-stress-3145195",
        "https://www.healthline.com/health/10-ways-to-relieve-stress",
        "https://www.helpguide.org/articles/stress/stress-management.htm",
        "https://www.apa.org/topics/stress/tips",
        "https://www.health.harvard.edu/mind-and-mood/protect-your-brain-from-stress",
        "https://www.webmd.com/balance/guide/tips-to-control-stress",
        "https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/stress/",
        "https://www.mind.org.uk/information-support/types-of-mental-health-problems/stress/",
        "https://www.psychologytoday.com/us/basics/stress"
    ],
    "sleepy": [
        "https://www.sleepfoundation.org/how-sleep-works/science-of-sleep",
        "https://www.mayoclinic.org/healthy-lifestyle/adult-health/in-depth/sleep/art-20048379",
        "https://www.healthline.com/health/healthy-sleep",
        "https://www.health.harvard.edu/topics/sleep",
        "https://www.helpguide.org/articles/sleep/getting-better-sleep.htm",
        "https://www.verywellhealth.com/the-importance-of-sleep-3014983",
        "https://www.nhs.uk/live-well/sleep-and-tiredness/",
        "https://www.webmd.com/sleep-disorders/ss/slideshow-sleep-tips",
        "https://www.psychologytoday.com/us/basics/sleep",
        "https://www.apa.org/topics/sleep/why"
    ]
}

def check_url_status(url):
    """Check if a URL is accessible and returns a valid page"""
    try:
        response = requests.head(url, headers=HEADERS, timeout=10, allow_redirects=True)
        
        # If head request fails, try a get request with a short timeout
        if response.status_code >= 400:
            response = requests.get(url, headers=HEADERS, timeout=5, allow_redirects=True, stream=True)
            # Just check the status without downloading the entire content
            response.close()
            
        return response.status_code < 400
    except Exception as e:
        print(f"Error checking URL {url}: {e}")
        return False

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

def create_emotion_description(metadata, emotion):
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
    
    # Create description for article
    title = metadata.get('title', 'Article')
    description = metadata.get('description', '')
    if description:
        # Use the first sentence or part of the description
        short_desc = description.split('.')[0]
        return f"{short_desc}. This article {chosen_phrase} when you're feeling {emotion}."
    else:
        return f"An insightful article that {chosen_phrase} when you're feeling {emotion}."

def find_replacement_url(emotion, used_urls):
    """Find a replacement URL for the given emotion that hasn't been used yet"""
    if emotion in REPLACEMENT_URLS:
        # Get all URLs for this emotion that aren't already in use
        available_urls = [url for url in REPLACEMENT_URLS[emotion] if url not in used_urls]
        
        # If we have available URLs, return the first one
        if available_urls:
            return available_urls[0]
        
        # If all URLs are used, append a unique query parameter to the first URL
        if REPLACEMENT_URLS[emotion]:
            return f"{REPLACEMENT_URLS[emotion][0]}?dup={len(used_urls)}"
    
    # Fallback to a generic URL if no emotion-specific URLs are available
    return "https://www.psychologytoday.com/us/basics/emotional-intelligence"

def fix_broken_article_links():
    """Find and fix broken article links in ContentData.json"""
    json_file_path = "SentimentSync/Resources/ContentData.json"
    
    # Load the content data
    with open(json_file_path, 'r') as f:
        content_data = json.load(f)
    
    # Get all article items
    articles = [(i, item) for i, item in enumerate(content_data) if item['type'] == 'article']
    
    print(f"Checking {len(articles)} articles for broken links...")
    
    # Track all URLs currently in use
    used_urls = set(item['url'] for item in content_data)
    
    # Track replacements
    replacements = 0
    checked = 0
    
    # Check each article URL
    for i, (idx, article) in enumerate(articles):
        url = article['url']
        emotion = article['emotion']
        
        checked += 1
        if checked % 5 == 0:
            print(f"Progress: {checked}/{len(articles)}")
        
        # Check if the URL is broken
        if not check_url_status(url):
            print(f"\nBroken link found: {url}")
            print(f"  Article: {article['title']}")
            print(f"  Emotion: {emotion}")
            
            # Find a replacement URL
            new_url = find_replacement_url(emotion, used_urls)
            print(f"  Replacing with: {new_url}")
            
            # Update the URL
            content_data[idx]['url'] = new_url
            used_urls.add(new_url)
            
            # Get metadata for the new URL
            metadata = get_article_metadata(new_url)
            
            # Update item if metadata was found
            if metadata:
                old_title = content_data[idx]['title']
                old_description = content_data[idx]['description']
                
                # Update title if it's different
                if 'title' in metadata and metadata['title']:
                    content_data[idx]['title'] = metadata['title']
                
                # Create and update description
                new_description = create_emotion_description(metadata, emotion)
                if new_description:
                    content_data[idx]['description'] = new_description
                
                # Report change
                print(f"  Updated title: {content_data[idx]['title']}")
                print(f"  Updated description: {content_data[idx]['description'][:50]}...")
            
            replacements += 1
            
            # Be nice to servers
            time.sleep(1)
    
    # Save changes
    if replacements > 0:
        with open(json_file_path, 'w') as f:
            json.dump(content_data, f, indent=4)
        print(f"\nReplaced {replacements} broken article links in {json_file_path}")
    else:
        print("\nNo broken article links found in the content data.")

if __name__ == "__main__":
    fix_broken_article_links() 