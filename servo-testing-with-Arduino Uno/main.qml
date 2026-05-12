import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 420
    height: 580
    title: "Servo Test"
    color: "#1e1e24" // Orijinal koyu tema

    // PYTHON'DAN GELEN SİNYALLERİ DİNLEME
    Connections {
        target: backend
        
        function onLogUpdated(msg) {
            logArea.text += msg + "\n"
            // Yeni log geldiğinde ekranı otomatik en alta kaydır
            logScroller.ScrollBar.vertical.position = 1.0 
        }
        
        function onStatusUpdated(isConnected, statusText) {
            statusLabel.text = statusText
            statusLabel.color = isConnected ? "#00ffcc" : "#ff3366"
        }
    }

    // Arayüz yüklendiğinde donanım bağlantısını başlat
    Component.onCompleted: {
        backend.init_hardware()
    }

    // ELEMANLARI DİKEY DİZME
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // ÜST BAŞLIK
        Text {
            text: "ACTUATOR CONTROL"
            font.family: "Consolas"
            font.pixelSize: 22
            font.bold: true
            color: "#ffffff"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // DURUM ÇUBUĞU
        Rectangle {
            width: parent.width
            height: 40
            color: "#2b2b36"
            radius: 5
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                Text { text: "System Status:"; font.family: "Consolas"; color: "#aaaaaa"; Layout.alignment: Qt.AlignLeft }
                Text { id: statusLabel; text: "INITIALIZING..."; font.family: "Consolas"; font.bold: true; color: "#aaaaaa"; Layout.alignment: Qt.AlignRight }
            }
        }

        // GÖRSEL KADRAN (GAUGE) ALANI
        Item {
            width: 320
            height: 160
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true // Dışarı taşan alt kısmı gizler (Böylece yarım daire elde ederiz)

            // Dış Kadran Çizgisi
            Rectangle {
                width: 320
                height: 320 // Tam daire
                radius: 160
                color: "transparent"
                border.color: "#444455"
                border.width: 4
                anchors.top: parent.top // Üstten hizalıyoruz ki alt yarısı clip:true sayesinde kopsun
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Derece Metinleri
            Text { text: "0°"; color: "#888899"; font.family: "Consolas"; anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 10; anchors.bottomMargin: 5 }
            Text { text: "90°"; color: "#888899"; font.family: "Consolas"; anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.topMargin: 10 }
            Text { text: "180°"; color: "#888899"; font.family: "Consolas"; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.rightMargin: 10; anchors.bottomMargin: 5 }

            // HAREKETLİ İBRE (NEEDLE)
            Rectangle {
                id: needle
                width: 4
                height: 140
                color: "#00ffcc"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                transformOrigin: Item.Bottom // İbre etrafında döneceği nokta (Alt orta kısım)
                
                // Matematiksel Sin/Cos yerine sadece açıyı veriyoruz
                // 0 derece = -90 (sola yatık) | 90 derece = 0 (dik) | 180 derece = +90 (sağa yatık)
                rotation: slider.value - 90 
                
                // İbrenin akıcı, yavaş ve hafif yaylanarak (OutBack) dönmesini sağlar
                Behavior on rotation {
                    NumberAnimation { duration: 400; easing.type: Easing.OutBack }
                }
            }

            // Merkez Noktası (Pin) ve Derece Göstergesi
            Rectangle {
                width: 70
                height: 70
                radius: 35
                color: "#1e1e24"
                border.color: "#444455"
                border.width: 3
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: -35 // Yarısı ekranın dışına taşsın
                
                Text {
                    text: Math.round(slider.value) + "°"
                    color: "#ffffff"
                    font.family: "Consolas"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -15
                }
            }
        }

        // KONTROL SLIDER'I
        Slider {
            id: slider
            from: 0
            to: 180
            value: 90
            stepSize: 1
            width: parent.width
            
            // Kullanıcı slider'ı sürüklemeyi/tıklamayı bıraktığında
            onPressedChanged: {
                if (!pressed) {
                    // Float değeri yuvarlayarak Python arka planına gönder
                    backend.transmit_command(Math.round(value))
                }
            }
        }

        // TELEMETRİ LOG EKRANI
        Text {
            text: "Telemetry Logs"
            font.family: "Consolas"
            font.pixelSize: 11
            color: "#888899"
        }

        ScrollView {
            id: logScroller
            width: parent.width
            height: 120
            background: Rectangle { color: "#121216"; radius: 5 }
            clip: true

            TextArea {
                id: logArea
                readOnly: true
                color: "#00ffcc" // Matrix yeşili terminal yazıları
                font.family: "Consolas"
                font.pixelSize: 11
                text: ""
                wrapMode: TextArea.Wrap
                
                // Arka planı şeffaf yap ki ana arka plan görünsün
                background: Rectangle { color: "transparent" } 
            }
        }
    }
}