import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels
import "."

Rectangle {
    id: root
    color: "#1e1e2e" // Base

    // ==================== PROPRIEDADES ====================
    property string currentChannel: "geral"
    property bool hasChannelSelected: currentChannel !== ""

    // ==================== CONEXÕES BACKEND ====================
    Connections {
        target: backend
        
        function onMessageReceived(channel, sender, message, displayTime, type) {
            if (channel === root.currentChannel) {
                chatModel.append({
                    "messageType": type,
                    "sender": sender,
                    "message": message,
                    "timestamp": "",
                    "displayTime": displayTime || "00:00"
                })
                chatListView.positionViewAtEnd()
            }
        }

        function onChannelHistoryLoaded(channel, messages) {
            // Atualizar o canal atual
            root.currentChannel = channel
            
            chatModel.clear()
            for (var i = 0; i < messages.length; i++) {
                var msg = messages[i]
                chatModel.append({
                    "messageType": msg.messageType,
                    "sender": msg.sender,
                    "message": msg.message,
                    "timestamp": msg.timestamp,
                    "displayTime": msg.displayTime
                })
            }
            chatListView.positionViewAtEnd()
        }
    }

    // ==================== MODELO DE DADOS ====================

    ListModel {
        id: chatModel
    }

    // ==================== UI ====================

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // Cabeçalho do Chat
        Rectangle {
            Layout.fillWidth: true
            height: 48
            color: "#1e1e2e"
            
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#313244" // Surface0
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                
                Label {
                    text: "#"
                    color: "#6c7086"
                    font.pixelSize: 20
                    font.bold: true
                }
                
                Label {
                    text: root.currentChannel
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
            }
        }

        // ListView de mensagens
        ListView {
            id: chatListView
            model: chatModel

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 12
            clip: true
            reuseItems: true

            visible: root.hasChannelSelected
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 8
                background: Rectangle { color: "transparent" }
                contentItem: Rectangle {
                    radius: 4
                    color: "#45475a"
                }
            }
            
            delegate: ColumnLayout {
                width: chatListView.width
                spacing: 4
                
                visible: model.messageType !== "system"
                
                Loader {
                    active: model.messageType === "system"
                    sourceComponent: systemMessageComp
                    Layout.fillWidth: true
                }
                
                Loader {
                    active: model.messageType !== "system"
                    sourceComponent: userMessageComp
                    Layout.fillWidth: true
                }

                Component {
                    id: systemMessageComp
                    RowLayout {
                        width: parent ? parent.width : 0
                        Layout.alignment: Qt.AlignHCenter
                        Label {
                            text: "→ " + model.message
                            color: "#6c7086"
                            font.pixelSize: 12
                            font.italic: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Component {
                    id: userMessageComp
                    RowLayout {
                        width: parent ? parent.width : 0
                        layoutDirection: model.messageType === "self" ? Qt.RightToLeft : Qt.LeftToRight
                        spacing: 10

                        // Balão de mensagem
                        ColumnLayout {
                            spacing: 2
                            
                            // Nome e Hora
                            RowLayout {
                                layoutDirection: Qt.LeftToRight 
                                Layout.alignment: model.messageType === "self" ? Qt.AlignRight : Qt.AlignLeft
                                
                                Label {
                                    text: model.sender
                                    color: model.messageType === "self" ? "#89b4fa" : "#f38ba8"
                                    font.bold: true
                                    font.pixelSize: 13
                                    visible: model.messageType !== "self"
                                }
                                
                                Label {
                                    text: model.displayTime
                                    color: "#6c7086"
                                    font.pixelSize: 11
                                }
                            }

                            Rectangle {
                                color: model.messageType === "self" ? "#89b4fa" : "#313244"
                                radius: 12
                                implicitWidth: msgText.implicitWidth + 24
                                implicitHeight: msgText.implicitHeight + 16
                                Layout.maximumWidth: chatListView.width * 0.7

                                Label {
                                    id: msgText
                                    anchors.centerIn: parent
                                    width: parent.width - 24
                                    text: model.message
                                    color: model.messageType === "self" ? "#1e1e2e" : "#cdd6f4"
                                    font.pixelSize: 14
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true } 
                    }
                }
            }
        }

        // Barra de entrada
        InputBar {
            id: inputBar
            Layout.fillWidth: true
            Layout.margins: 16
            Layout.bottomMargin: 20

            onSendMessage: (msg) => {
                backend.sendMessage(root.currentChannel, msg)
            }
        }
    }
}
