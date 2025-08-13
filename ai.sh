DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
function youtube_transcript () {
  if [ -z $1 ]; then
      echo "Provide URL to Youtube video as argument"
  else
    local output=$(yt-dlp --skip-download \
      --write-subs \
      --write-auto-subs \
      --sub-lang en \
      "$1")
    local filename=$(echo "$output" | sed -n 's/.*estination: \(.*\)/\1/p')
    echo "Downloaded filename: ${filename}"
    cat "$filename" | \
      sed '/^$/d' | \
      grep -v '^[0-9]*$' | \
      grep -v '\-->' | \
      sed 's/<[^>]*>//g' | \
      tr '\n' ' ' | \
      sed 's/&nbsp;/ /g' > "output-${filename}.txt"
  fi
}

function ai_youtube_summary () {
  if [ -z $1 ]; then
    echo "Provide URL to Youtube video as argument"
  else
    source $DIR/scripts/venv/bin/activate
    python $DIR/scripts/claude_youtube.py -u $1
    deactivate
  fi
}

function claude_youtube () {
  source $DIR/scripts/venv/bin/activate
  python $DIR/scripts/claude_youtube.py "$@"
  deactivate
}

function tokenizer () {
  source $DIR/scripts/venv/bin/activate
  python $DIR/scripts/tokenizer.py "$@"
  deactivate
}

function transcribe() {
    if [ -z "$1" ]; then
        echo "Usage: transcribe <video_file>"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: File '$1' not found"
        return 1
    fi

    if ! command -v ffmpeg &> /dev/null; then
      echo "Error: Required command 'ffmpeg' not found"
      return 1
    fi

    if ! command -v whisper &> /dev/null; then
      echo "Error: Required command 'whisper' not found" 
      return 1
    fi

    local input_file="$1"

    echo "Transcribing: $input_file"
    rm temp-output.wav
    ffmpeg -i "$input_file" -ar 16000 -ac 1 -c:a pcm_s16le -f wav > temp-output.wav | \
    # whisper temp-output.wav --model medium --output_format txt > "${input_file}_transcript.txt"
    
    echo "Transcript saved in:"
}