import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels

Rectangle {
    color: "#2A2B38" // 2C2C3F
    property string currentChannel: "geral"//tenho que arrumar isso

    ListModel {
        id: chatModel
        ListElement{ messageType:"self"; sender: "Você"; message: "aaaaaaaaaaaaaa"; is_self: true; timestamp: "2025-11-06T17:30:00Z"; displayDate: "06/11/2025"; displayTime: "17:30"}
        ListElement{ messageType:"other";sender: "OutroUser"; message: "bbbbbbbbbbbbbbbbb"; is_self: false; timestamp: "2025-11-06T17:31:00Z";displayDate: "06/11/2025"; displayTime: "17:31"}
        ListElement{ messageType:"other";sender: "Carlos"; message: "cccccccccccccccccccccccccccccccccccccccccccccccccccc"; is_self: true; timestamp: "2025-11-06T17:31:30Z"; displayDate: "06/11/2025"; displayTime: "17:31"}
        ListElement{ messageType:"system";sender: "Admin"; message: "Amanda entou no canal"; is_self: false; timestamp: "2025-11-06T17:32:00Z"; displayDate: "06/11/2025"; displayTime: "17:32"}
        ListElement{ messageType:"self";sender: "Você"; message: "d"; is_self: false; timestamp: "2025-11-06T17:32:00Z"; displayDate: "06/11/2025"; displayTime: "17:32"}
    }



    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Título do Canal
        Label {
            id: channelTitle
            color: "white"
            text: "Canal: #" + currentChannel
            font.bold: true
            font.pixelSize: 18
        }
        ListView {
            id: chatListView
            model: chatModel

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 14
            clip: false//
            reuseItems: true

            boundsBehavior: Flickable.StopAtBounds//pode merda
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            Component.onCompleted: chatListView.positionViewAtEnd()


            delegate: DelegateChooser {
                // 1. O 'role' (propriedade) continua o mesmo
                role: "messageType"

                // 2. Delegate para "other"
                DelegateChoice {
                    roleValue: "other"
                    MessageDelegateOther { }
                }

                // 3. Delegate para "self"
                DelegateChoice {
                    roleValue: "self"
                    MessageDelegateSelf { }
                }

                //4. Delegate para "system"
                DelegateChoice {
                    roleValue: "system"
                    SystemMessageDelegate { } // vou pensar
                }
            }
        }




        InputBar {
            id: inputBar

            Layout.fillWidth: true
            onSendMessage: (msg) => {
                var now = new Date()
                //var isoString = now.toISOString()
                var date = now.toLocaleDateString(undefined,{year: 'numeric', month: '2-digit', day:'2-digit'})
                var time = now.toLocaleTimeString(undefined,{hour: '2-digit', minute: '2-digit'})

                chatModel.append({
                    sender: "Você",message:msg, messageType: "self", timestamp: now.toISOString(), displayDate: date, displayTime: time
                })
                chatListView.positionViewAtEnd()
            }
        }

    }


}



