# 🚀 Actuator Telemetry & Control Interface

Bu proje, donanım birimlerinin (aktüatör/servo) seri port üzerinden gerçek zamanlı kontrolünü ve telemetri takibini sağlayan Nesne Yönelimli (OOP) mimariyle geliştirilmiş bir masaüstü arayüzüdür. 

Özellikle robotik, gömülü sistemler ve insansız araç projelerinde karşılaşılan "donanım-yazılım entegrasyonu" ve "haberleşme güvenliği" sorunlarına çözüm üretmek amacıyla kavram kanıtı (Proof of Concept) olarak tasarlanmıştır.

## ✨ Öne Çıkan Özellikler

* **Gerçek Zamanlı Görselleştirme:** Trigonometrik hesaplamalarla anlık çalışan görsel kadran (Gauge) ve ibre sistemi.
* **Telemetri Loglama:** Gönderilen komutların (TX) ve donanımdan gelen yanıtların (RX) zaman damgalı (timestamp) takibi.
* **Hata Toleransı (Fault Tolerance):** Port kopmaları veya donanım arızalarında sistemin çökmesini engelleyen güvenli haberleşme döngüsü.
* **OOP Mimarisi:** Temiz, yönetilebilir ve modüler Python sınıf (class) yapısı.

## 🛠️ Kullanılan Teknolojiler

* **Backend / Arayüz:** Python 3.x, Tkinter (GUI), Math
* **Haberleşme:** PySerial (RS232/USB Serial Communication)
* **Donanım:** Arduino (C++), SG90/MG995 Servo Motor

## ⚙️ Kurulum ve Çalıştırma

### 1. Donanım Hazırlığı
Arduino üzerindeki bağlantıları aşağıdaki gibi yapın:
* **Servo Sinyal Pini** ➜ Arduino Pin 9
* Servo VCC ve GND bağlantılarını güç kaynağına bağlayın.
* Depoda bulunan `arduino_code.ino` (veya ilgili C++ kodu) dosyasını karta yükleyin.

### 2. Yazılım Ortamı
Gerekli Python kütüphanesini kurun:
```bash
pip install pyserial