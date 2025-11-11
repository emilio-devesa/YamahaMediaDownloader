# Contributing to Yamaha Media Downloader

Thank you for your interest in contributing! 🎶

This project is still growing, and any help improving code quality, documentation, or usability is highly appreciated.

---

## 🧭 Project Overview

**Yamaha Media Downloader** is a Python tool designed to automatically download educational audio files from official **Yamaha Music School** pages for various instruments.  

It uses Selenium WebDriver to automate browser interactions and save all audio tracks locally with descriptive filenames.

---

## 🧰 How to Contribute

There are several ways to contribute:

### 1. 🐞 Report Issues
If you encounter a bug, please open an issue on GitHub and include:
- A clear description of the problem
- Steps to reproduce it
- Your OS and Python version
- Any relevant error messages

### 2. 💡 Suggest Improvements
Feel free to suggest:
- New features (e.g. support for more instruments)
- Code optimizations
- UX improvements or setup simplifications

### 3. 🔧 Submit Code
If you’d like to submit code:
1. **Fork** the repository  
2. Create a new branch for your change:
    ```
    git checkout -b feature/add-piano-support
    ```
3. Make your modifications following the **style guide** below
4. Test your changes
5. Submit a **Pull Request**

## 🧑‍💻 Development Setup

1. Clone the repository
```
git clone https://github.com/emilio-devesa/YamahaMediaDownloader.git
cd YamahaMediaDownloader
```
2. Setup your environment
Run the automated setup:
```
./setup.sh
```
This script will:
- Create and activate a Python virtual environment
- Install all dependencies listed in `requirements.txt`
- Detect your installed browser (Brave, Chrome, Edge, or Safari)
- Extract its version and automatically install the correct WebDriver
- Store the browser path and environment settings in a `.env` file for future runs

Alternatively, you can set them manually in a `.env` file. For example:
```
BROWSER="brave"
BROWSER_PATH="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
CHROMEDRIVER_PATH="/usr/local/bin/chromedriver"
```

3. Run the downloader
```
python src/yamaha_media_downloader.py drums_1
```

## 🧩 Code Style Guidelines

Please follow these conventions:
- Use **PEP 8** for Python style consistency
- Use **English** for variable names, comments, and commits
- Keep functions small and readable
- Use `f-strings` for formatting
- Handle exceptions gracefully (avoid bare `except:`)

## 🧪 Testing

Before submitting a pull request:
- Test with at least one Yamaha course link (e.g. `drums_1`)
- Confirm that audio files are downloaded correctly and named properly
- Ensure compatibility on macOS (primary development environment)

## 🗂️ Repository Structure

```
YamahaMediaDownloader/
│
├── src/                    # Main Python scripts
├── ├── browser_factory.py
│   └── yamaha_media_downloader.py
│
├── data/
│   └── courses.txt         # Course URLs (key=value)
│
├── setup.sh                # Environment setup script
├── requirements.txt        # Dependencies
├── README.md               # Documentation
├── LICENSE                 # GNU GPL 3 License information
└── CONTRIBUTING.md         # Contribution guidelines

```

## 💬 Communication

If you have questions, ideas, or need guidance:
- Open a **Discussion** on GitHub
- Comment on existing issues or pull requests
- Polite and constructive collaboration is encouraged at all times. 😊

## 🪪 License Notice

This repository is for **educational and personal use only**.

All Yamaha audio materials remain the property of **Yamaha Corporation**.

Thank you for contributing!

Let’s make Yamaha Media Downloader more powerful and useful together 🎧