#!/bin/bash

# Pitch Shift Download Script
# Downloads audio from YouTube and applies pitch shifting using ffmpeg
# Usage: ./pitch-shift-download.sh <youtube_url> [pitch_factor]

set -e  # Exit on any error

# Default values
PITCH_FACTOR=${2:-0.943874}  # Default to half-step down

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed or not in PATH"
        echo "Please install $1 to continue."
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <youtube_url> [pitch_factor]"
    echo ""
    echo "Arguments:"
    echo "  youtube_url   YouTube URL to download audio from (required)"
    echo "  pitch_factor  Pitch adjustment factor (optional, default: 0.943874 = half-step down)"
    echo ""
    echo "Note: Output files will be saved in the 'shifted/' directory using the video title"
    echo ""
    echo "Common pitch factors:"
    echo "  1.059463      +1 semitone (half-step up)"
    echo "  0.943874      -1 semitone (half-step down)"
    echo "  1.122462      +2 semitones (whole step up)"
    echo "  0.890899      -2 semitones (whole step down)"
    echo "  1.259921      +3 semitones (minor third up)"
    echo "  0.793701      -3 semitones (minor third down)"
    echo ""
    echo "Examples:"
    echo "  $0 'https://youtu.be/wMFpXL4A11I'"
    echo "  $0 'https://youtu.be/wMFpXL4A11I' 1.059463"
    exit 1
}

# Check if URL is provided
if [ $# -lt 1 ]; then
    print_error "YouTube URL is required"
    show_usage
fi

YOUTUBE_URL=$1

# Validate URL (basic check)
if [[ ! $YOUTUBE_URL =~ youtube\.com|youtu\.be ]]; then
    print_warning "URL doesn't appear to be a YouTube URL. Continuing anyway..."
fi

# Check required commands
print_status "Checking required dependencies..."
check_command "yt-dlp"
check_command "ffmpeg"

# Create temp directory for intermediate files
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

print_status "Temporary files will be stored in: $TEMP_DIR"

# Download audio using yt-dlp
print_status "Downloading audio from YouTube..."
DOWNLOADED_FILE="$TEMP_DIR/%(title)s.%(ext)s"

if ! yt-dlp -x --audio-format mp3 -o "$DOWNLOADED_FILE" "$YOUTUBE_URL"; then
    print_error "Failed to download audio from YouTube"
    exit 1
fi

# Find the downloaded MP3 file
INPUT_FILE=$(find "$TEMP_DIR" -name "*.mp3" -type f | head -n 1)

if [ -z "$INPUT_FILE" ]; then
    print_error "No MP3 file found after download"
    exit 1
fi

print_status "Downloaded: $(basename "$INPUT_FILE")"

# Create output directory
mkdir -p "shifted"

# Extract the title from the downloaded filename (remove extension)
VIDEO_TITLE=$(basename "$INPUT_FILE" .mp3)
print_status "Video title: $VIDEO_TITLE"

# Get the actual sample rate of the input file
print_status "Detecting input sample rate..."
INPUT_SR=$(ffprobe -v error -select_streams a:0 \
  -show_entries stream=sample_rate -of default=nw=1:nk=1 "$INPUT_FILE")

if [ -z "$INPUT_SR" ]; then
    print_error "Failed to detect input sample rate"
    exit 1
fi

print_status "Input sample rate: ${INPUT_SR} Hz"

# Calculate tempo compensation to maintain playback speed
TEMPO=$(awk "BEGIN{printf \"%.6f\", 1/${PITCH_FACTOR}}")
print_status "Tempo compensation factor: $TEMPO"

# Apply pitch shifting with ffmpeg using proper sample rate and tempo compensation
OUTPUT_FILE="shifted/${VIDEO_TITLE}_pitch-shifted.mp3"
print_status "Applying pitch shift (factor: $PITCH_FACTOR)..."
print_status "Output file: $OUTPUT_FILE"

if ! ffmpeg -i "$INPUT_FILE" \
    -af "asetrate=${INPUT_SR}*${PITCH_FACTOR},aresample=${INPUT_SR},atempo=${TEMPO}" \
    -y "$OUTPUT_FILE"; then
    print_error "Failed to apply pitch shift with ffmpeg"
    exit 1
fi

print_status "Successfully created pitch-shifted audio: $OUTPUT_FILE"

# Show file info
if command -v ffprobe &> /dev/null; then
    echo ""
    print_status "Output file information:"
    ffprobe -v quiet -show_entries format=duration,bit_rate,size -show_entries stream=codec_name,sample_rate,channels -of compact=p=0:nk=1 "$OUTPUT_FILE"
fi

print_status "Done! 🎵"