import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: inputBar
    implicitHeight: 50
    color: "#313244" // Surface0
    radius: 25 // Pill shape

    signal sendMessage(string msg)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        // Espaçamento esquerdo
        Item { width: 8 }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter
            
            TextArea {
                id: messageField
                placeholderText: "Enviar mensagem para #" + (parent.parent.parent.parent.currentChannel || "canal")
                color: "#cdd6f4"
                placeholderTextColor: "#6c7086"
                font.pixelSize: 14
                wrapMode: TextEdit.Wrap
                verticalAlignment: TextEdit.AlignVCenter
                selectByMouse: true
                
                background: null // Remove background padrão do TextArea
                
                Keys.onReturnPressed: (event) => {
                    if (!(event.modifiers & Qt.ShiftModifier)) {
                        event.accepted = true
                        if (messageField.text.trim().length > 0) {
                            sendMessage(messageField.text.trim())
                            messageField.text = ""
                        }
                    }
                }
            }
        }

        Button {
            id: sendButton
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            
            background: Rectangle {
                radius: 21
                color: sendButton.hovered ? "#89b4fa" : "transparent" // Blue on hover
            }
            
            contentItem: Label {
                text: "➤"
                color: sendButton.hovered ? "#1e1e2e" : "#bac2de"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                if (messageField.text.trim().length > 0) {
                    sendMessage(messageField.text.trim())
                    messageField.text = ""
                }
            }
        }
    }
}
