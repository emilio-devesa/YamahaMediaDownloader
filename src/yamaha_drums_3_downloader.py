import os
from dotenv import load_dotenv
import re
import time
import requests
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

# ---------- CONFIGURACIÓN ----------
URL = "https://yms.ymm.co.jp/media/?page=98a57e2cb7ef5d9c408286963a9768c3"
DEST_FOLDER = os.path.join(os.getcwd(), "yamaha_drums_3")
os.makedirs(DEST_FOLDER, exist_ok=True)


# ---------- OPCIONES DEL NAVEGADOR ----------
options = Options()
options.binary_location = BRAVE_PATH  # ← se carga desde .env
# options.add_argument("--headless")  # Puedes descomentar esto si quieres que no abra ventana
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

driver = webdriver.Chrome(service=Service(CHROMEDRIVER_PATH), options=options)
wait = WebDriverWait(driver, 20)

print("Abriendo la página de Yamaha...")
driver.get(URL)
time.sleep(5)

# ---------- ACEPTAR COOKIES ----------
try:
    accept_btn = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "button, .accept-button")))
    accept_btn.click()
    print("Cookies aceptadas.")
    time.sleep(2)
except:
    pass

# ---------- FUNCIONES AUXILIARES ----------
def sanitize_filename(name: str) -> str:
    """Elimina caracteres no válidos en nombres de archivo."""
    name = re.sub(r'[<>:"/\\|?*]', '_', name)
    name = re.sub(r'\s+', ' ', name).strip()
    return name

def download_audio(audio_url, filename):
    if not audio_url or not audio_url.endswith(".mp3"):
        print(f"⚠️  URL inválida para {filename}: {audio_url}")
        return
    filepath = os.path.join(DEST_FOLDER, f"{filename}.mp3")
    try:
        r = requests.get(audio_url, timeout=15)
        r.raise_for_status()
        with open(filepath, "wb") as f:
            f.write(r.content)
        print(f"✅ Descargado: {filename}")
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

        # Esperar a que el <audio> tenga src
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
