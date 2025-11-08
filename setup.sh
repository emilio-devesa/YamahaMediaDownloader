#!/usr/bin/env bash

echo "🔧 Setting up Yamaha Media Downloader..."

# Detect Python version
PYTHON_BIN=$(command -v python3 || command -v python)
if [ -z "$PYTHON_BIN" ]; then
  echo "❌ Python not found. Please install Python 3 first."
  exit 1
fi

# Create virtual environment
if [ ! -d "venv" ]; then
  echo "📦 Creating virtual environment..."
  $PYTHON_BIN -m venv venv
else
  echo "✅ Virtual environment already exists."
fi

# Activate environment
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Detect Brave (default path on macOS)
DEFAULT_BRAVE_PATH="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

echo ""
echo "👉 Brave Browser setup"
read -p "Enter the full path to Brave Browser [$DEFAULT_BRAVE_PATH]: " BRAVE_PATH
BRAVE_PATH=${BRAVE_PATH:-$DEFAULT_BRAVE_PATH}

if [ ! -f "$BRAVE_PATH" ]; then
  echo "❌ Could not find Brave at: $BRAVE_PATH"
  echo "Please check your installation path."
  exit 1
fi

#Detect ChromeDriver (default path on macOS)
echo ""
echo "👉 ChromeDriver setup"
DEFAULT_CHROMEDRIVER_PATH="$HOME/chromedriver/chromedriver"
read -p "Enter the full path to ChromeDriver [$DEFAULT_CHROMEDRIVER_PATH]: " CHROMEDRIVER_PATH
CHROMEDRIVER_PATH=${CHROMEDRIVER_PATH:-$DEFAULT_CHROMEDRIVER_PATH}

if [ ! -f "$CHROMEDRIVER_PATH" ]; then
  echo "❌ Could not find ChromeDriver at: $CHROMEDRIVER_PATH"
  exit 1
fi

# Save configuration
echo "BRAVE_PATH=\"$BRAVE_PATH\"" > .env
echo "✅ Saved Brave Browser path to .env"
echo "CHROMEDRIVER_PATH=\"$CHROMEDRIVER_PATH\"" >> .env
echo "✅ Saved ChromeDriver path to .env"

# Ensure chromedriver exists or download it
if [ ! -f "/usr/local/bin/chromedriver" ] && [ ! -f "$HOME/chromedriver/chromedriver" ]; then
  echo "⬇️ Installing latest ChromeDriver..."
  pip install webdriver-manager
  echo "✅ ChromeDriver will be managed automatically by WebDriver Manager."
else
  echo "✅ ChromeDriver detected."
fi

echo "🎉 Setup complete!"
echo "To activate your environment, run: source venv/bin/activate"
