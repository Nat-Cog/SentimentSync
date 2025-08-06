#!/usr/bin/env python3
import json
import requests
import time
from urllib.parse import urlparse

def get_replacement_url(emotion, content_type):
    """Generate a replacement URL based on emotion and content type."""
    replacements = {
        # Video replacements (YouTube)
        ('happy', 'video'): 'https://www.youtube.com/watch?v=ZbZSe6N_BXs',  # Happy - Pharrell Williams
        ('sad', 'video'): 'https://www.youtube.com/watch?v=2Vv-BfVoq4g',  # Lewis Capaldi - Someone You Loved
        ('angry', 'video'): 'https://www.youtube.com/watch?v=5abamRO41fE',  # Counting and breathing exercise
        ('scared', 'video'): 'https://www.youtube.com/watch?v=WWloIAQpMcQ',  # Calming video
        ('romantic', 'video'): 'https://www.youtube.com/watch?v=lJJT00wqlOo',  # Ed Sheeran - Perfect
        ('relaxed', 'video'): 'https://www.youtube.com/watch?v=uCD-qMfBWDM',  # Calming ocean waves
        ('lost', 'video'): 'https://www.youtube.com/watch?v=QkrJWE1uG-c',  # Finding yourself motivation
        ('stressed', 'video'): 'https://www.youtube.com/watch?v=O-6f5wQXSu8',  # Stress relief meditation
        ('sleepy', 'video'): 'https://www.youtube.com/watch?v=qYnA9wWFHLI',  # Sleep music
        
        # Song replacements (Spotify)
        ('happy', 'song'): 'https://open.spotify.com/track/60nZcImufyMA1MKQY3dcCH',  # Happy - Pharrell Williams
        ('sad', 'song'): 'https://open.spotify.com/track/4kflIGfjdZJW4ot2ioixTB',  # Someone Like You - Adele
        ('angry', 'song'): 'https://open.spotify.com/track/5Jz8r4W1lf5Yz2tYb2Eo3f',  # Killing In The Name - RATM
        ('scared', 'song'): 'https://open.spotify.com/track/1zfzka5Vqk6xS3s0FEMlkJ',  # Disturbia - Rihanna
        ('romantic', 'song'): 'https://open.spotify.com/track/0tgVpDi06FyKpA1z0VMD4v',  # Perfect - Ed Sheeran
        ('relaxed', 'song'): 'https://open.spotify.com/track/3Ofmpyhv5UAQ70mENzB277',  # Sunset Lover - Petit Biscuit
        ('lost', 'song'): 'https://open.spotify.com/track/5AyEXCtuYybv20QovpGOLM',  # Runaway Train - Soul Asylum
        ('stressed', 'song'): 'https://open.spotify.com/track/6dGnYIeXmHdcikdzNNDMm2',  # Here Comes The Sun - Beatles
        ('sleepy', 'song'): 'https://open.spotify.com/track/7qD8bspQhiZUTfqdLBq32Q',  # Clair de Lune
        
        # Quote replacements (Goodreads)
        ('happy', 'quote'): 'https://www.goodreads.com/quotes/tag/happiness',
        ('sad', 'quote'): 'https://www.goodreads.com/quotes/tag/sadness',
        ('angry', 'quote'): 'https://www.goodreads.com/quotes/tag/anger',
        ('scared', 'quote'): 'https://www.goodreads.com/quotes/tag/fear',
        ('romantic', 'quote'): 'https://www.goodreads.com/quotes/tag/romance',
        ('relaxed', 'quote'): 'https://www.goodreads.com/quotes/tag/relaxation',
        ('lost', 'quote'): 'https://www.goodreads.com/quotes/tag/lost',
        ('stressed', 'quote'): 'https://www.goodreads.com/quotes/tag/stress',
        ('sleepy', 'quote'): 'https://www.goodreads.com/quotes/tag/sleep',
        
        # Article replacements
        ('happy', 'article'): 'https://positivepsychology.com/benefits-of-happiness/',
        ('sad', 'article'): 'https://www.psychologytoday.com/us/blog/emotional-fitness/201907/why-crying-is-good-you',
        ('angry', 'article'): 'https://www.psychologytoday.com/us/blog/click-here-happiness/202104/managing-anger-tips-techniques-and-tools',
        ('scared', 'article'): 'https://tinybuddha.com/blog/let-go-of-fear-by-stopping-the-stories-in-your-head/',
        ('romantic', 'article'): 'https://www.psychologytoday.com/us/basics/romantic-love',
        ('relaxed', 'article'): 'https://www.healthline.com/health/breathing-exercises-for-anxiety',
        ('lost', 'article'): 'https://greatergood.berkeley.edu/article/item/seven_ways_to_find_your_purpose_in_life',
        ('stressed', 'article'): 'https://www.mayoclinic.org/healthy-lifestyle/stress-management/in-depth/stress-relievers/art-20047257',
        ('sleepy', 'article'): 'https://www.sleepfoundation.org/how-sleep-works/science-of-sleep'
    }
    
    key = (emotion, content_type)
    return replacements.get(key, None)

def check_urls(json_file_path):
    """Check each URL in the ContentData.json file."""
    with open(json_file_path, 'r') as f:
        content_data = json.load(f)
    
    replacements = []
    total_urls = len(content_data)
    checked = 0
    
    print(f"Checking {total_urls} URLs...")
    
    # Set of domains we already know are valid to avoid rechecking
    valid_domains = set()
    problem_domains = set()
    
    for item in content_data:
        url = item['url']
        domain = urlparse(url).netloc
        
        # Skip rechecking domains we already validated
        if domain in valid_domains:
            checked += 1
            if checked % 20 == 0:
                print(f"Progress: {checked}/{total_urls} URLs checked")
            continue
            
        # Mark domains we already know have problems
        if domain in problem_domains:
            replacement_url = get_replacement_url(item['emotion'], item['type'])
            if replacement_url:
                replacements.append({
                    'id': item['id'],
                    'title': item['title'],
                    'old_url': url,
                    'new_url': replacement_url,
                    'emotion': item['emotion'],
                    'type': item['type']
                })
            checked += 1
            if checked % 20 == 0:
                print(f"Progress: {checked}/{total_urls} URLs checked")
            continue
        
        try:
            # Use head request to avoid downloading large content
            headers = {'User-Agent': 'Mozilla/5.0 (compatible; URLChecker/1.0)'}
            response = requests.head(url, timeout=10, allow_redirects=True, headers=headers)
            
            # Some sites block head requests, try GET if head fails
            if response.status_code >= 400:
                response = requests.get(url, timeout=10, headers=headers, stream=True)
                # Just check the status and close the connection
                response.close()
                
            if response.status_code >= 400:
                print(f"Error {response.status_code} for URL: {url}")
                problem_domains.add(domain)
                
                replacement_url = get_replacement_url(item['emotion'], item['type'])
                if replacement_url:
                    replacements.append({
                        'id': item['id'],
                        'title': item['title'],
                        'old_url': url,
                        'new_url': replacement_url,
                        'emotion': item['emotion'],
                        'type': item['type']
                    })
            else:
                valid_domains.add(domain)
                
        except requests.exceptions.RequestException as e:
            print(f"Error checking URL {url}: {e}")
            problem_domains.add(domain)
            
            replacement_url = get_replacement_url(item['emotion'], item['type'])
            if replacement_url:
                replacements.append({
                    'id': item['id'],
                    'title': item['title'],
                    'old_url': url,
                    'new_url': replacement_url,
                    'emotion': item['emotion'],
                    'type': item['type']
                })
                
        # Be nice to servers
        time.sleep(0.5)
        
        checked += 1
        if checked % 20 == 0:
            print(f"Progress: {checked}/{total_urls} URLs checked")
    
    return replacements

def update_content_data(json_file_path, replacements):
    """Update the ContentData.json file with the replacement URLs."""
    with open(json_file_path, 'r') as f:
        content_data = json.load(f)
    
    # Create a map of item IDs to make lookups faster
    replacements_map = {r['id']: r['new_url'] for r in replacements}
    
    # Update the URLs
    updated_count = 0
    for item in content_data:
        if item['id'] in replacements_map:
            item['url'] = replacements_map[item['id']]
            updated_count += 1
    
    # Write the updated data back to the file
    with open(json_file_path, 'w') as f:
        json.dump(content_data, f, indent=4)
    
    print(f"Updated {updated_count} URLs in {json_file_path}")

if __name__ == "__main__":
    json_file_path = "SentimentSync/Resources/ContentData.json"
    
    print("Checking URLs in ContentData.json...")
    replacements = check_urls(json_file_path)
    
    if replacements:
        print(f"\nFound {len(replacements)} URLs that need to be replaced.")
        print("\nReplacements:")
        for r in replacements:
            print(f"- {r['title']} ({r['emotion']}, {r['type']}):")
            print(f"  Old: {r['old_url']}")
            print(f"  New: {r['new_url']}")
            print()
        
        choice = input("Update ContentData.json with these replacements? (y/n): ")
        if choice.lower() == 'y':
            update_content_data(json_file_path, replacements)
    else:
        print("All URLs are working correctly!") 