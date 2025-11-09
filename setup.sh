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
DEFAULT_BRAVE_PATH="/Applications/Brave Browser.app"

echo ""
echo "👉 Brave Browser setup"
read -p "Enter the full path to Brave Browser app [$DEFAULT_BRAVE_PATH]: " USER_INPUT
USER_INPUT=${USER_INPUT:-$DEFAULT_BRAVE_PATH}

# Remove quotes (both single and double)
USER_INPUT=$(echo "$USER_INPUT" | sed "s/^['\"]//;s/['\"]$//")

# Normalize path: if ends with .app, append binary path
if [[ "$USER_INPUT" == *.app ]]; then
  BRAVE_PATH="$USER_INPUT/Contents/MacOS/Brave Browser"
else
  BRAVE_PATH="$USER_INPUT"
fi

# Validate Brave Binary
if [ ! -f "$BRAVE_PATH" ]; then
  echo "❌ Could not find Brave at: $BRAVE_PATH"
  echo "Please check your installation path."
  deactivate
  exit 1
fi

# Default ChromeDriver path on macOS
echo ""
echo "👉 ChromeDriver setup"
DEFAULT_CHROMEDRIVER_PATH="/usr/local/bin/chromedriver"

# Ensure chromedriver exists or download it
if [ ! -f "$DEFAULT_CHROMEDRIVER_PATH" ]; then
  echo "⬇️ Installing latest ChromeDriver..."
  pip install webdriver-manager
  echo "✅ ChromeDriver will be managed automatically by WebDriver Manager."
else
  echo "✅ ChromeDriver detected at $DEFAULT_CHROMEDRIVER_PATH."
fi

# Save configuration
echo ""
echo "📝 Saving configuration..."
{
  echo "BRAVE_PATH=\"$BRAVE_PATH\""
  echo "CHROMEDRIVER_PATH=\"$DEFAULT_CHROMEDRIVER_PATH\""
} > .env

echo "✅ Configuration saved to .env file."

echo ""
echo "🎉 Setup complete!"
echo "To activate your environment later, run: source venv/bin/activate"
