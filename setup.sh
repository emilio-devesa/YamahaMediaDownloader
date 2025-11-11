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

echo ""
echo "🌐 Choose your browser:"
echo "1) Brave"
echo "2) Chrome"
echo "3) Edge"
echo "4) Safari"
read -p "Select an option [1-4]: " BROWSER_CHOICE

case $BROWSER_CHOICE in
    1)
        BROWSER="brave"
        DEFAULT_PATH="/Applications/Brave Browser.app"
        ;;
    2)
        BROWSER="chrome"
        DEFAULT_PATH="/Applications/Google Chrome.app"
        ;;
    3)
        BROWSER="edge"
        DEFAULT_PATH="/Applications/Microsoft Edge.app"
        ;;
    4)
        BROWSER="safari"
        ;;
    *)
        echo "❌ Invalid option."
        deactivate
        exit 1
    ;;
esac

BRAVE_PATH=""
CHROMEDRIVER_PATH=""

if [ "$BROWSER" != "safari" ]; then
    echo ""
    echo "👉 Browser setup for $BROWSER"
    read -p "Enter the full path to the browser app [$DEFAULT_PATH]: " USER_INPUT
    USER_INPUT=${USER_INPUT:-$DEFAULT_PATH}
    USER_INPUT=$(echo "$USER_INPUT" | sed "s/^['\"]//;s/['\"]$//")

    # Append internal binary path if ends with .app
    if [[ "$USER_INPUT" == *.app ]]; then
    case $BROWSER in
        brave)
            BROWSER_PATH="$USER_INPUT/Contents/MacOS/Brave Browser"
            ;;
        chrome)
            BROWSER_PATH="$USER_INPUT/Contents/MacOS/Google Chrome"
            ;;
        edge)
            BROWSER_PATH="$USER_INPUT/Contents/MacOS/Microsoft Edge"
            ;;
    esac
    else
        BROWSER_PATH="$USER_INPUT"
    fi

    if [ ! -f "$BROWSER_PATH" ]; then
        echo "❌ Could not find browser binary at: $BROWSER_PATH"
        deactivate
        exit 1
    fi

    # Chrome/Brave/Edge use ChromeDriver or MSEdgeDriver
    DEFAULT_CHROMEDRIVER_PATH="/usr/local/bin/chromedriver"
    DEFAULT_EDGEDRIVER_PATH="/usr/local/bin/msedgedriver"

    echo ""
    echo "🔍 Checking for WebDriver..."
    if [ "$BROWSER" = "edge" ]; then
        DRIVER_PATH="$DEFAULT_EDGEDRIVER_PATH"
        DRIVER_NAME="msedgedriver"
    else
        DRIVER_PATH="$DEFAULT_CHROMEDRIVER_PATH"
        DRIVER_NAME="chromedriver"
    fi

    if [ ! -f "$DRIVER_PATH" ]; then
        echo "⬇️ Installing webdriver-manager..."
        pip install webdriver-manager
        echo "✅ WebDriver will be managed automatically by WebDriver Manager."
    else
        echo "✅ Found $DRIVER_NAME at $DRIVER_PATH"
    fi
else
    echo ""
    echo "🧩 Safari selected: no path required."
    echo "Make sure to enable 'Allow Remote Automation' in Safari’s Develop menu."
fi

# Save configuration
{
  echo "BROWSER=\"$BROWSER\""
  [ "$BROWSER" != "safari" ] && echo "BROWSER_PATH=\"$BROWSER_PATH\""
  [ "$BROWSER" = "brave" -o "$BROWSER" = "chrome" ] && echo "CHROMEDRIVER_PATH=\"$DEFAULT_CHROMEDRIVER_PATH\""
  [ "$BROWSER" = "edge" ] && echo "EDGEDRIVER_PATH=\"$DEFAULT_EDGEDRIVER_PATH\""
} > .env

echo "✅ Configuration saved to .env file."

echo ""
echo "🎉 Setup complete!"
echo "To activate your environment later, run: source venv/bin/activate"
