import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    // Fundo da área de chat
    color: "#2A2B38" // 2C2C3F Cor original do seu arquivo [cite: 35]

    // Propriedade para definir o canal atual (Melhoria)
    property string currentChannel: "geral"

    // O modelo de dados agora inclui um 'sender' (Melhoria)
    ListModel {
        id: chatModel
        ListElement{ sender: "Você"; message: "aaaaaaaaaaaaaa"; is_self: true}
        ListElement{ sender: "OutroUser"; message: "bbbbbbbbbbbbbbbbb"; is_self: false}
        ListElement{ sender: "Você"; message: "cccccccccccccccccccccccccccccccccccccccccccccccccccc"; is_self: true}
        ListElement{ sender: "Admin"; message: "dddddddddddd❤️🙈😳🤳💀💕💕❤️❤️"; is_self: false}
    }


    // 1. O LAYOUT PRINCIPAL FOI CORRIGIDO (Melhoria)
    // Este ColumnLayout agora organiza tudo, do topo à base.
    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 10 // Margem que você tinha no 'rectangle' [cite: 35]
        spacing: 6

        // Título do Canal (agora dinâmico)
        Label {
            id: channelTitle
            color: "white"
            text: "Canal: #" + currentChannel // Usa a nova propriedade [cite: 47]
            font.bold: true
            font.pixelSize: 18
        }
        ListView {
            id: chatListView
            model: chatModel

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 10
            clip: true
            reuseItems: true

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            Component.onCompleted: chatListView.positionViewAtEnd()


            delegate: Item {
                height: messageContainer.height
                width: chatListView.width


                Rectangle{
                    id:messageContainer
                    //width: chatListView.width * 0.7
                    width: messageText.width + senderText.width //* 0.7
                    //height: messageText.implicitHeight + 20
                    height: columnChatArea.implicitHeight + 20
                    //color: "#7E32BC"
                    radius: 5

                    //color: model.is_self ? "#00E6FF" : "#C800FF"


                    color: model.is_self ? "#7E32BC" : "#62417D"
                    //color:  "transparent"

                    // Lógica de alinhamento testada
                    anchors.right: model.is_self ? parent.right : undefined
                    anchors.left: model.is_self ? undefined : parent.left


                    //color: model.is_self ? "#dcf8c6" : "#ffffff"
                    //border.color: "#e0e0e0"

                    ColumnLayout{
                        id: columnChatArea
                        //width: parent.width
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        Text{
                            id: senderText
                            text: model.sender

                            color: model.is_self ? "white" : "#00C8FF"
                            font.bold: true
                            Layout.fillWidth: true

                            horizontalAlignment: model.is_self ? Text.AlignRight : Text.AlignLeft

                            // anchors.leftMargin: 10
                            // anchors.rightMargin: 10
                            // anchors.topMargin: 10

                        }

                        Text {
                            id: messageText
                            text: model.message
                            color: "white" // Cor do texto explícita
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true

                            horizontalAlignment: model.is_self ? Text.AlignRight : Text.AlignLeft

                            // anchors.left: parent.left
                            // anchors.right: parent.right

                            //anchors.leftMargin: 10
                            // anchors.rightMargin: 10
                            // anchors.bottomMargin: 10
                        }
                    }
                }
            }
        }


        InputBar {
            id: inputBar

            Layout.fillWidth: true
            onSendMessage: (msg) => {
                chatModel.append({sender:"Você",message:msg, is_self: true})
                chatListView.positionViewAtEnd()
            }
        }

    }


}



