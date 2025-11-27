import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#1e1e2e" // Base

    property string title: ""

    default property alias contentItem: contentContainer.data

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Cabeçalho da Sidebar
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "transparent"
            
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: root.title.toUpperCase()
                color: "#6c7086" // Overlay0
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1.2
            }
        }

        // Container para o conteúdo (ListView)
        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
        }
    }
}
