# Yamaha Media Downloader

This project contains Python scripts that automatically download all practice audios from the **Yamaha books** available on the official Yamaha Music School media pages.

Each script opens the target page in a **Chromium-based browser (Brave)**, simulates clicks to load every audio file, and saves them locally with proper filenames.

---

## 📦 Requirements

- macOS (tested)
- [Python 3.10+](https://www.python.org/downloads/)
- [Brave Browser](https://brave.com/download/)
- [ChromeDriver](https://googlechromelabs.github.io/chrome-for-testing/) compatible with your Brave version
- Internet connection

---

## 🚀 Setup & Installation

This project includes automatic setup scripts for macOS to make installation easy.

### 1. Clone the repository
```
git clone https://github.com/emilio-devesa/YamahaMediaDownloader.git
cd YamahaMediaDownloader
```

### 2. Install
```
./setup.sh
```
These scripts will:
- Create and activate a Python virtual environment
- Install all dependencies listed in requirements.txt
- Check for Brave Browser (used by the scripts)
- Automatically manage ChromeDriver using webdriver-manager

### 3. Activate environment
```
source venv/bin/activate
```

### 5. Use the script
Each script corresponds to one Yamaha book. For example:
```
python src/yamaha_drums_1_downloader.py
```
The audio files will be saved in a folder in the same directory where the script is executed. The folder will have a descriptive name, e.g.:
```
yamaha_drums_1/
```

## ⚙️ Requirements
- Python 3.9 or higher
- Brave Browser installed
- Internet connection

## 🧩 Notes

The scripts use Selenium WebDriver to control Brave (Chromium).
You can enable headless mode by uncommenting this line:
```
# options.add_argument("--headless")
``` 

Each audio file keeps the name shown in the Yamaha Media list (e.g. `02-01 Chapter 1 - 4th Rhythm Pattern 2.mp3`).

## 🪪 License

This repository is for educational and personal use only.
All rights to the audio content belong to Yamaha Corporation.

