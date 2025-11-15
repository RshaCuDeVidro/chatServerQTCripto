import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels
import "."

Rectangle {
    id: root
    color: "#2A2B38" // 2C2C3F
    property string currentChannel: ""
    property bool hasChannelSelected: currentChannel !== ""

    ListModel {
        id: chatModel
        ListElement{ messageType:"self"; sender: "Você"; message: "aaaaaaaaaaaaaa"; timestamp: "2025-11-06T17:30:00Z"; displayDate: "06/11/2025"; displayTime: "17:30"}
        ListElement{ messageType:"other";sender: "OutroUser"; message: "bbbbbbbbbbbbbbbbb"; timestamp: "2025-11-06T17:31:00Z";displayDate: "06/11/2025"; displayTime: "17:31"}
        ListElement{ messageType:"other";sender: "Carlos"; message: "cccccccccccccccccccccccccccccccccccccccccccccccccccc";timestamp: "2025-11-06T17:31:30Z"; displayDate: "06/11/2025"; displayTime: "17:31"}
        ListElement{ messageType:"system";sender: "Admin"; message: "Amanda entou no canal"; timestamp: "2025-11-06T17:32:00Z"; displayDate: "06/11/2025"; displayTime: "17:32"}
        ListElement{ messageType:"self";sender: "Você"; message: "d"; timestamp: "2025-11-06T17:32:00Z"; displayDate: "06/11/2025"; displayTime: "17:32"}
    }

    Component.onCompleted: {
            // Quando um canal é selecionado
            EventBus.channelSelected.connect(function(channelName) {
                root.currentChannel = channelName
                EventBus.log("ChatArea: Canal mudou para", channelName)

                // Aqui você pode carregar histórico do backend
                // EventBus.loadingStateChanged("chatHistory", true)
                // backend.loadChannelHistory(channelName)
            })

            // Quando uma mensagem é recebida
            EventBus.messageReceived.connect(function(channel, messageData) {
                // Só adiciona se for do canal atual
                if (channel === root.currentChannel) {
                    chatModel.append(messageData)
                    chatListView.positionViewAtEnd()
                    EventBus.log("Mensagem recebida no canal", channel)
                } else {
                    // Incrementa contador de não lidas
                    EventBus.log("Mensagem em outro canal:", channel)
                    // Aqui você incrementaria o contador
                }
            })

            // Quando histórico é carregado
            EventBus.channelHistoryLoaded.connect(function(channel, messages) {
                if (channel === root.currentChannel) {
                    chatModel.clear()
                    for (var i = 0; i < messages.length; i++) {
                        chatModel.append(messages[i])
                    }
                    chatListView.positionViewAtEnd()
                    EventBus.loadingStateChanged("chatHistory", false)
                }
            })
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
            text: root.hasChannelSelected
                ? "Canal: #" + root.currentChannel
                : "Selecione um canal"
            font.bold: true
            font.pixelSize: 18
            opacity: root.hasChannelSelected ? 1.0 : 0.5

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        // Placeholder quando nenhum canal selecionado
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.hasChannelSelected

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16

                Label {
                    text: "👈"
                    font.pixelSize: 48
                    color: "#888888"
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Selecione um canal\npara começar"
                    font.pixelSize: 16
                    color: "#888888"
                    horizontalAlignment: Text.AlignHCenter
                     Layout.alignment: Qt.AlignHCenter
                }
            }
        }


        ListView {
            id: chatListView
            model: chatModel

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 8
            clip: true//
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
            visible: root.hasChannelSelected
            enabled: root.hasChannelSelected

            onSendMessage: (msg) => {
                var now = new Date()
                // Apenas emite o evento - o próprio ChatArea escutará e adicionará
                EventBus.emitMessageReceived(
                    root.currentChannel,
                    "Você",
                    msg,
                    "self",
                    now
                )

                EventBus.log("Mensagem enviada:", {
                    channel: root.currentChannel,
                    message: msg
                })

                // Backend também será notificado via EventBus (no main.qml)
            }
        }
    }
}



