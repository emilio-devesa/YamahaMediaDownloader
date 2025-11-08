import os
import sys
import time
import re
import requests
from dotenv import load_dotenv
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

# ---------- CARGAR VARIABLES DE ENTORNO ----------
load_dotenv()
BRAVE_PATH = os.getenv("BRAVE_PATH", "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser")
CHROMEDRIVER_PATH = os.getenv("CHROMEDRIVER_PATH", "/usr/local/bin/chromedriver")

# ---------- LEER ARGUMENTO ----------
if len(sys.argv) < 2:
    print("❌ Usa: python yamaha_downloader.py <COURSE_KEY>")
    print("Ejemplo: python yamaha_downloader.py VOCAL_EXTENSION")
    sys.exit(1)

COURSE_KEY = sys.argv[1].upper()

# ---------- LEER ARCHIVO DE CURSOS ----------
COURSE_FILE = os.path.join(os.path.dirname(__file__), "../data/courses.txt")
if not os.path.exists(COURSE_FILE):
    print(f"❌ No se encontró el archivo de cursos: {COURSE_FILE}")
    sys.exit(1)

course_url = None
with open(COURSE_FILE, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        key, _, value = line.partition("=")
        if key.strip().upper() == COURSE_KEY:
            course_url = value.strip()
            break

if not course_url:
    print(f"❌ No se encontró la clave '{COURSE_KEY}' en courses.txt")
    sys.exit(1)

# ---------- CONFIGURACIÓN ----------
DEST_FOLDER = os.path.join(os.getcwd(), f"yamaha_{COURSE_KEY.lower()}")
os.makedirs(DEST_FOLDER, exist_ok=True)

# ---------- OPCIONES DEL NAVEGADOR ----------
options = Options()
options.binary_location = BRAVE_PATH
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

driver = webdriver.Chrome(service=Service(CHROMEDRIVER_PATH), options=options)
wait = WebDriverWait(driver, 20)

print(f"🌐 Abriendo el curso '{COURSE_KEY}'...")
driver.get(course_url)
time.sleep(5)

# ---------- ACEPTAR COOKIES ----------
try:
    accept_btn = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "button, .accept-button")))
    accept_btn.click()
    print("🍪 Cookies aceptadas.")
    time.sleep(2)
except:
    pass

# ---------- FUNCIONES AUXILIARES ----------
def sanitize_filename(name: str) -> str:
    name = re.sub(r'[<>:"/\\|?*]', '_', name)
    name = re.sub(r'\s+', ' ', name).strip()
    return name

def download_audio(audio_url, filename):
    if not audio_url or not (audio_url.endswith(".mp3") or audio_url.endswith(".mp4")):
        print(f"⚠️  URL inválida para {filename}: {audio_url}")
        return
    ext = ".mp4" if audio_url.endswith(".mp4") else ".mp3"
    filepath = os.path.join(DEST_FOLDER, f"{filename}{ext}")
    try:
        r = requests.get(audio_url, timeout=15)
        r.raise_for_status()
        with open(filepath, "wb") as f:
            f.write(r.content)
        print(f"✅ Descargado: {filename}{ext}")
    except Exception as e:
        print(f"❌ Error descargando {filename}: {e}")

# ---------- BUCLE PRINCIPAL ----------
track_num = 1
while True:
    audio_links = driver.find_elements(By.CSS_SELECTOR, 'a[href^="javascript:playthis"]')
    total = len(audio_links)
    if track_num > total:
        break

    try:
        link = audio_links[track_num - 1]
        title = sanitize_filename(link.text or f"Pista_{track_num:03d}")
        driver.execute_script("arguments[0].scrollIntoView(true);", link)
        time.sleep(0.5)
        driver.execute_script("arguments[0].click();", link)

        audio_elem = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "audio")))
        src = None
        for _ in range(20):
            new_src = audio_elem.get_attribute("src")
            if new_src and new_src != src:
                src = new_src
                break
            time.sleep(0.5)

        if src:
            download_audio(src, title)
        else:
            print(f"⚠️ No se encontró URL de audio para {title}")

    except Exception as e:
        print(f"❌ Error en pista {track_num}: {e}")

    track_num += 1
    time.sleep(1)

driver.quit()
print("🎉 Descarga completada.")
