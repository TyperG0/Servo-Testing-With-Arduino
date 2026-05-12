import sys
import time
import serial
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal

class ActuatorBackend(QObject):
    # QML (Arayüz) tarafına anlık veri göndermek için Sinyaller oluşturuyoruz
    logUpdated = Signal(str)
    statusUpdated = Signal(bool, str)

    def __init__(self):
        super().__init__()
        self.PORT = 'COM8' # Donanım portun
        self.BAUD_RATE = 9600
        self.arduino = None
        self.is_connected = False

    @Slot()
    def init_hardware(self):
        """Arayüz açılır açılmaz QML tarafından çağrılan ilk bağlantı fonksiyonu."""
        try:
            self.arduino = serial.Serial(self.PORT, self.BAUD_RATE, timeout=0.5)
            time.sleep(2) # Bağlantı stabilizasyonu
            self.is_connected = True
            # Bağlantı başarılıysa QML'e yeşil renkli online mesajı için sinyal gönder
            self.statusUpdated.emit(True, f"ONLINE ({self.PORT})")
            self.logUpdated.emit(self.format_log("System initialized. Awaiting commands."))
        except Exception:
            self.arduino = None
            self.is_connected = False
            # Bağlantı yoksa QML'e kırmızı renkli offline mesajı için sinyal gönder
            self.statusUpdated.emit(False, "OFFLINE / PORT ERROR")
            self.logUpdated.emit(self.format_log("ERROR: Hardware not found on specified port."))

    @Slot(int)
    def transmit_command(self, angle):
        """QML'deki slider bırakıldığında tetiklenen haberleşme fonksiyonu."""
        if not self.is_connected:
            self.logUpdated.emit(self.format_log("TX_FAILED: No active hardware connection."))
            return

        command_packet = f"S1:{angle}\n"
        try:
            # Komutu donanıma gönder
            self.arduino.write(command_packet.encode('utf-8'))
            self.logUpdated.emit(self.format_log(f"TX: {command_packet.strip()}"))
            
            # Yanıtı bekle
            response = self.arduino.readline().decode('utf-8').strip()
            
            if "OK" in response:
                self.logUpdated.emit(self.format_log(f"RX: ACK received. Position: {angle}°"))
            else:
                self.logUpdated.emit(self.format_log("RX_WARN: No acknowledgment from hardware."))
        except Exception as e:
            self.logUpdated.emit(self.format_log(f"SYS_ERROR: {str(e)}"))

    def format_log(self, message):
        """Loglara zaman damgası ekleyen yardımcı fonksiyon."""
        timestamp = time.strftime("%H:%M:%S")
        return f"[{timestamp}] {message}"


# UYGULAMAYI BAŞLATMA
if __name__ == "__main__":
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Backend sınıfımızı QML'in içine "backend" adıyla enjekte ediyoruz
    actuator_backend = ActuatorBackend()
    engine.rootContext().setContextProperty("backend", actuator_backend)

    # QML dosyasını yükle
    engine.load("main.qml")

    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())