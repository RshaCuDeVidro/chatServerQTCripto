import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: inputBar
    height: 60
    width: parent ? parent.width : 400
    color: "#2f3136"

    signal sendMessage(string msg)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: 6

            TextField {
                id: messageField
                Layout.fillWidth: true
                placeholderText: "Digite sua mensagem..."
                color: "white"
                wrapMode: Text.NoWrap
                focus: true
                overwriteMode: true
                activeFocusOnPress: true
                placeholderTextColor: "#7561f2"
                background: Rectangle {
                    color: "#40444b"
                    radius: 4
                }

                Keys.onEnterPressed:{
                    if(messageField.text.length > 0){
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }

                Keys.onReturnPressed:{
                    if(messageField.text.length > 0){
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }
            }
//#5a8fd9
//#2f02c4
            Button {
                id: sendButton
                visible: true
                text: "Enviar"
                flat: false
                highlighted: true
                 background:Rectangle {
                     color: "#7561f2"
                     radius: 4
                }
                Layout.bottomMargin: 3
                icon.width: 25
                onClicked: {
                    if (messageField.text.length > 0) {
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }



                Keys.onEnterPressed:{
                    if(messageField.text.length > 0){
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }

                Keys.onReturnPressed:{
                    if(messageField.text.length > 0){
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }



            }
        }
    }
}
