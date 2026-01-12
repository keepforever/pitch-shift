# Pitch Shift Download Script

A bash script that downloads audio from YouTube and applies pitch shifting using ffmpeg. Perfect for musicians who want to change the key of songs for practice or performance.

## Quick Start

**Basic usage (downloads and pitch-shifts half-step down):**

```bash
./pitch-shift-download.sh 'https://youtu.be/wMFpXL4A11I'
```

This single command will:

1. Download the audio as MP3 from YouTube
2. Pitch-shift it down by a half-step (semitone)
3. Save it as `pitch-shifted.mp3`

## What It Does

### Step-by-Step Process

1. **Downloads Audio**: Uses `yt-dlp` to extract audio from YouTube videos in MP3 format
2. **Applies Pitch Shifting**: Uses `ffmpeg` with the formula `asetrate=44100*factor,aresample=44100`
3. **Saves Result**: Outputs the pitch-shifted audio to your specified filename

### Default Behavior

- **Pitch Factor**: `0.943874` (half-step down)
- **Output File**: `pitch-shifted.mp3`
- **Audio Format**: MP3 at 44.1kHz sample rate

## Installation Requirements

You need these tools installed on your system:

### macOS (using Homebrew)

```bash
brew install yt-dlp ffmpeg
```

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install yt-dlp ffmpeg
```

### Windows

- Install [yt-dlp](https://github.com/yt-dlp/yt-dlp#installation)
- Install [ffmpeg](https://ffmpeg.org/download.html)

## Usage Examples

### Basic Usage

```bash
# Download and pitch-shift half-step down (default)
./pitch-shift-download.sh 'https://youtu.be/wMFpXL4A11I'
```

### Custom Pitch Factors

```bash
# Half-step up
./pitch-shift-download.sh 'https://youtu.be/wMFpXL4A11I' 1.059463

# Whole step down
./pitch-shift-download.sh 'https://youtu.be/wMFpXL4A11I' 0.890899

# Minor third up
./pitch-shift-download.sh 'https://youtu.be/wMFpXL4A11I' 1.259921
```

### Custom Output Names

```bash
# Specify output filename
./pitch-shift-download.sh 'https://youtu.be/wMFpXL4A11I' 0.943874 'my-song-lower'
```

## Pitch Factor Reference

| Interval           | Semitones | Factor       | Description                    |
| ------------------ | --------- | ------------ | ------------------------------ |
| Minor 3rd up       | +3        | 1.259921     | 3 semitones higher             |
| Whole step up      | +2        | 1.122462     | 2 semitones higher             |
| Half-step up       | +1        | 1.059463     | 1 semitone higher              |
| **Original**       | **0**     | **1.000000** | **No change**                  |
| **Half-step down** | **-1**    | **0.943874** | **Default (1 semitone lower)** |
| Whole step down    | -2        | 0.890899     | 2 semitones lower              |
| Minor 3rd down     | -3        | 0.793701     | 3 semitones lower              |

## Script Features

### ✅ Smart Defaults

- Automatically pitch-shifts half-step down (most common use case)
- Uses sensible output filename (`pitch-shifted.mp3`)
- Maintains 44.1kHz audio quality

### ✅ Error Handling

- Checks for required dependencies (`yt-dlp` and `ffmpeg`)
- Validates YouTube URLs
- Handles temporary files with automatic cleanup
- Provides clear error messages with colored output

### ✅ Flexible Options

- Custom pitch factors for any interval
- Custom output filenames
- Works with any YouTube URL format

### ✅ Clean Operation

- Uses temporary directory for intermediate files
- Automatically cleans up after completion
- No leftover files cluttering your workspace

## Technical Details

### Audio Processing Chain

```bash
YouTube Video → yt-dlp → Raw MP3 → ffmpeg → Pitch-Shifted MP3
```

### FFmpeg Command Used

```bash
ffmpeg -i input.mp3 \
  -af "asetrate=44100*0.943874,aresample=44100" \
  output.mp3
```

This command:

- `asetrate=44100*factor`: Changes playback rate (affects pitch and speed)
- `aresample=44100`: Resamples back to standard 44.1kHz (corrects speed)
- Result: Pitch change without speed change

### File Handling

- Downloads to temporary directory using `mktemp -d`
- Processes in temp space to avoid conflicts
- Moves final result to current working directory
- Cleans up all temporary files automatically

## Troubleshooting

### Common Issues

**"yt-dlp not found"**

```bash
# Install yt-dlp
brew install yt-dlp  # macOS
sudo apt install yt-dlp  # Linux
```

**"ffmpeg not found"**

```bash
# Install ffmpeg
brew install ffmpeg  # macOS
sudo apt install ffmpeg  # Linux
```

**"No MP3 file found after download"**

- Check if the YouTube video is available in your region
- Verify the URL is correct and accessible
- Some videos may have download restrictions

**Permission denied**

```bash
# Make script executable
chmod +x pitch-shift-download.sh
```

### Getting Help

Run the script without arguments to see usage information:

```bash
./pitch-shift-download.sh
```

## Example Workflow

For musicians practicing with backing tracks:

```bash
# Download original song
./pitch-shift-download.sh 'https://youtu.be/song-url' 1.0 'original'

# Create half-step down version for different key
./pitch-shift-download.sh 'https://youtu.be/song-url' 0.943874 'half-step-down'

# Create whole-step down version
./pitch-shift-download.sh 'https://youtu.be/song-url' 0.890899 'whole-step-down'
```

Now you have the same song in multiple keys for practice! 🎵
