import os
import re
import subprocess
import urllib.request
import json
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.edge.service import Service as EdgeService
from selenium.webdriver.edge.options import Options as EdgeOptions
from selenium.webdriver.safari.webdriver import WebDriver as SafariDriver
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.microsoft import EdgeChromiumDriverManager


def detect_browser_version(binary_path):
    """Detect major version of browser (Brave/Chrome/Edge)"""
    try:
        result = subprocess.run([binary_path, "--version"], capture_output=True, text=True)
        match = re.search(r"(\d+\.\d+\.\d+\.\d+)", result.stdout)
        if match:
            version = match.group(1)
            print(f"🧭 Detected browser version: {version}")
            return version
    except Exception as e:
        print(f"⚠️ Could not detect browser version: {e}")
    return None


def get_chromedriver_url(version):
    """Get ChromeDriver download URL for a specific version (from Chrome for Testing API)"""
    try:
        major = version.split(".")[0]
        url = f"https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
        with urllib.request.urlopen(url) as response:
            data = json.load(response)
        for item in data["versions"]:
            if item["version"].startswith(major + "."):
                downloads = item["downloads"]["chromedriver"]
                for d in downloads:
                    if d["platform"] == "mac-x64":
                        return d["url"]
    except Exception as e:
        print(f"⚠️ Could not fetch ChromeDriver URL: {e}")
    return None


def download_chromedriver(version):
    """Force download correct driver version from Chrome for Testing"""
    url = get_chromedriver_url(version)
    if not url:
        print("❌ Could not find ChromeDriver for version", version)
        return None
    print(f"⬇️ Downloading ChromeDriver for version {version}...")
    subprocess.run(["curl", "-LO", url], check=True)
    subprocess.run(["unzip", "-o", "chromedriver-mac-x64.zip", "-d", "drivers"], check=True)
    driver_path = os.path.abspath("drivers/chromedriver-mac-x64/chromedriver")
    print(f"✅ Installed ChromeDriver at {driver_path}")
    return driver_path


def get_browser_driver():
    browser = os.getenv("BROWSER", "brave").lower()
    binary_path = os.getenv("BROWSER_PATH")

    if browser in ["brave", "chrome"]:
        options = ChromeOptions()
        if binary_path:
            options.binary_location = binary_path

        version = detect_browser_version(binary_path)
        driver_path = None

        if version:
            driver_path = download_chromedriver(version)

        if not driver_path:
            print("⚙️ Falling back to WebDriver Manager...")
            driver_path = ChromeDriverManager().install()

        return webdriver.Chrome(service=ChromeService(driver_path), options=options)

    elif browser == "edge":
        options = EdgeOptions()
        return webdriver.Edge(service=EdgeService(EdgeChromiumDriverManager().install()), options=options)

    elif browser == "safari":
        print("🦊 Using Safari system WebDriver...")
        return SafariDriver()

    else:
        raise ValueError(f"❌ Unsupported browser: {browser}")
