// StyledSidebar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    color: "#2A2B38"

    // Propriedade para definir o título
    property string title: ""

    // Propriedade onde o conteúdo será inserido
    default property alias contentItem: contentContainer.data

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // Título
        Label {
            text: root.title
            color: "#F0F0F5"
            font.pixelSize: 16
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true

            layer.enabled: true
            layer.effect: DropShadow {
                color: "#da00c8ff"
                radius: 5
                spread: 0.2
                transparentBorder: true
                samples: 10
                cached: true
            }
        }

        // Container com borda e sombra
        Rectangle {
            id: container
            color: "#2C2C3F"
            radius: 8
            border.color: "#C800FF"
            border.width: 1.5
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: false

            // Sombra animada
            RectangularShadow {
                color: "#C800FF"
                anchors.fill: parent
                z: -1
                blur: 14
                radius: 8
                spread: 4
                cached: true

                PropertyAnimation on blur {
                    easing.bezierCurve: [0.42, 0, 0.58, 1]
                    running: true
                    loops: -1
                    from: 18
                    to: 14
                    duration: 1500
                }

                PropertyAnimation on spread {
                    easing.bezierCurve: [0.42, 0, 0.58, 1]
                    running: true
                    loops: -1
                    from: 7
                    to: 4
                    duration: 1500
                }
            }

            // Container para o conteúdo (ListView)
            Item {
                id: contentContainer
                anchors.fill: parent
                clip: true
            }
        }
    }
}
