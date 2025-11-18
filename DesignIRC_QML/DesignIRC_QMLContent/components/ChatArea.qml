import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels
import "."

Rectangle {
    id: root
    color: "#2A2B38"

    // ==================== PROPRIEDADES ====================
    property string currentChannel: ""
    property bool hasChannelSelected: currentChannel !== ""

    // ==================== MODELO DE DADOS ====================

    ListModel {
        id: chatModel
    }

    // ==================== MUDANÇA: Escuta EventBus ====================

    Component.onCompleted: {
        // Quando canal é selecionado
        eventBus.channelSelected.connect(function(channelName) {
            root.currentChannel = channelName
            chatModel.clear() // Limpa mensagens antigas
            eventBus.log("ChatArea: Canal mudou para", channelName)
        })

        // Quando mensagem é recebida
        eventBus.messageReceived.connect(function(channel, messageData) {
            // Só adiciona se for do canal atual
            if (channel === root.currentChannel) {
                addMessage(messageData)
                eventBus.log("ChatArea: Mensagem adicionada")
            }
        })

        // Quando histórico é carregado
        eventBus.channelHistoryLoaded.connect(function(channel, messages) {
            if (channel === root.currentChannel) {
                loadHistory(messages)
                eventBus.log("ChatArea: Histórico carregado", messages.length + " msgs")
            }
        })
    }

    // ==================== FUNÇÕES PÚBLICAS ====================

    function addMessage(messageData) {
        // Garante que tem todos os campos necessários
        var msg = {
            messageType: messageData.messageType || "other",
            sender: messageData.sender || messageData.username || "Desconhecido",
            message: messageData.message || "",
            timestamp: messageData.timestamp || new Date().toISOString(),
            displayDate: messageData.displayDate || formatDate(messageData.timestamp),
            displayTime: messageData.displayTime || formatTime(messageData.timestamp)
        }

        chatModel.append(msg)
        chatListView.positionViewAtEnd()
    }

    function loadHistory(messages) {
        chatModel.clear()

        for (var i = 0; i < messages.length; i++) {
            var msg = messages[i]

            // Determina tipo baseado no usuário atual
            var msgType = "other"
            if (typeof backend !== 'undefined' && msg.username === backend.currentUser) {
                msgType = "self"
            } /*else if (msg.username === "Você") {
                msgType = "self"
            }*/

            addMessage({
                messageType: msgType,
                sender: msg.username,
                message: msg.message,
                timestamp: msg.timestamp,
                displayDate: formatDate(msg.timestamp),
                displayTime: formatTime(msg.timestamp)
            })
        }

        chatListView.positionViewAtEnd()
    }

    function addSystemMessage(text) {
        addMessage({
            messageType: "system",
            sender: "Sistema",
            message: text,
            timestamp: new Date().toISOString()
        })
    }

    function clearMessages() {
        chatModel.clear()
    }

    // Funções auxiliares de formatação
    function formatDate(timestamp) {
        if (!timestamp) return ""

        var date = typeof timestamp === 'string' ? new Date(timestamp) : timestamp
        return date.toLocaleDateString(undefined, {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        })
    }

    function formatTime(timestamp) {
        if (!timestamp) return ""

        var date = typeof timestamp === 'string' ? new Date(timestamp) : timestamp
        return date.toLocaleTimeString(undefined, {
            hour: '2-digit',
            minute: '2-digit'
        })
    }

    // ==================== UI ====================

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

        // ListView de mensagens
        ListView {
            id: chatListView
            model: chatModel

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 8
            clip: true
            reuseItems: true

            visible: root.hasChannelSelected
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            Component.onCompleted: chatListView.positionViewAtEnd()

            delegate: DelegateChooser {
                role: "messageType"

                DelegateChoice {
                    roleValue: "other"
                    MessageDelegateOther { }
                }

                DelegateChoice {
                    roleValue: "self"
                    MessageDelegateSelf { }
                }

                DelegateChoice {
                    roleValue: "system"
                    SystemMessageDelegate { }
                }
            }
        }

        // Barra de entrada
        InputBar {
            id: inputBar

            Layout.fillWidth: true
            visible: root.hasChannelSelected
            enabled: root.hasChannelSelected

            // ==================== CORRETO: Usa EventBus ====================
            onSendMessage: (msg) => {
                appCoordinator.sendMessage(root.currentChannel, msg)
                // Apenas notifica via EventBus
                // O Coordinator no main.qml escutará e decidirá o que fazer
                // eventBus.emitMessageReceived(
                //     root.currentChannel,
                //     "Você",  // Será substituído pelo currentUser no Coordinator
                //     msg,
                //     "self",
                //     new Date()
                // )
            }
        }
    }
}
