import argparse
import os
import re
import requests
import sys
import warnings
from pathlib import Path
from yt_dlp import YoutubeDL
from urllib3.exceptions import InsecureRequestWarning

# Currently insecure due to disabling of cert validation (corporate firewall)

CLAUDE_MODEL = "claude-3-haiku-20240307"


def download_transcript(youtube_url: str) -> str:
    if not youtube_url:
        print("Provide URL to Youtube video as argument")
        return None

    ydl_opts = {
        'skip_download': True,
        'writesubtitles': True,
        'writeautomaticsub': True,
        'subtitleslangs': ['en'],
        'quiet': True,
        'nocheckcertificate': True
    }
    
    try:
        with YoutubeDL(ydl_opts) as ydl:
            with warnings.catch_warnings():
                warnings.simplefilter("ignore", InsecureRequestWarning)
                info = ydl.extract_info(youtube_url, download=True)
            video_title = info['title']
            
            vtt_path = info['requested_subtitles']['en']['filepath']
            subtitle_file = vtt_path if os.path.isfile(vtt_path) else None

            output_filename = f"{video_title}_transcript.txt"
            with open(subtitle_file, 'r') as f:
              subtitle_content = f.read()
            output = cleanup_transcript(subtitle_content)
            with open(output_filename, 'w') as f:
                f.write(output)
            os.remove(subtitle_file)
            
            return output_filename
            
    except Exception as e:
        print(f"An error occurred: {e}")
        return None
      

def cleanup_transcript(vtt_text: str):
    # Remove timestamp lines (00:00:00.000 --> 00:00:00.000)
    output = re.sub(r'\d{2}:\d{2}:\d{2}\.\d{3}\s*-->\s*\d{2}:\d{2}:\d{2}\.\d{3}.*\n', '', vtt_text)
    
    # Remove positioning information (align:start position:0%)
    output = re.sub(r'align:start position:\d+%.*\n', '', output)
    
    # Remove <c> tags and their timestamps
    output = re.sub(r'<\/?c>|\<\d{2}:\d{2}:\d{2}\.\d{3}\>', '', output)
    
    # Remove empty lines
    output = re.sub(r'\n\s*\n', '\n', output)
    
    # Remove leading/trailing whitespace
    output = output.strip()
    
    # Split into lines and remove duplicates while preserving order
    seen = set()
    unique_lines = []
    for line in output.split('\n'):
        line = line.strip()
        if line and line not in seen:
            seen.add(line)
            unique_lines.append(line)
    return ' '.join(unique_lines)
  

def ask_claude(prompt):
    # Disable SSL verification warnings due to corporate proxies
    warnings.filterwarnings('ignore', category=InsecureRequestWarning)
    session = requests.Session()
    session.verify = False
      
    url = "https://api.anthropic.com/v1/messages"
    headers = {
      "x-api-key": os.getenv("ANTHROPIC_API_KEY"),
      "Content-Type": "application/json",
      "anthropic-version": "2023-06-01"
    }
    data = {
      "model": CLAUDE_MODEL,
      "max_tokens": 1024,
      "messages": [{"role": "user", "content": prompt}]
    }
    response = session.post(url, headers=headers, json=data)
    response.raise_for_status()
    text = response.json()['content'][0]['text']
    return text


def main():
    parser = argparse.ArgumentParser(description="Download and process YouTube video subtitles.")
    parser.add_argument('-u', '--url', type=str, required=True, help='YouTube video URL')
    parser.add_argument('-k', '--keep', action='store_true', help='Flag: Keep the transcript file after processing')
    parser.add_argument('-p', '--prompt', type=str, default='', help='Supplemental prompt to add, e.g. specific question')
    args = parser.parse_args()
  
    if not os.getenv("ANTHROPIC_API_KEY"):
        print("Error: ANTHROPIC_API_KEY environment variable is not set.")
        sys.exit(1)

    try:
        supp_prompt = f", with an emphasis on the following: {args.prompt}"
        transcript = download_transcript(args.url)
        with open(transcript, 'r') as file:
            transcript_content = file.read()
            prompt = f"Summarize this video transcript{supp_prompt}: {transcript_content}"
        response = ask_claude(prompt)
        print(response)
        if not args.keep:
            os.remove(transcript)

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()