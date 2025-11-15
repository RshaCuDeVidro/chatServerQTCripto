import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: mainWindow
    visible: true
    minimumWidth: 800
    minimumHeight: 600
    width: 1000
    height: 600
    title: "IRC das Putas"

    // ==================== EVENTBUS COMO PROPRIEDADE ====================

    property QtObject eventBus: QtObject {
        id: _eventBus
        objectName: "EventBus"

        // Sinais de canal
        signal channelSelected(string channelName)
        signal messageReceived(string channel, var messageData)
        signal channelHistoryLoaded(string channel, var messages)
        signal unreadCountChanged(string channel, int count)

        // Sinais de usuário
        signal userStatusChanged(string userName, string status)
        signal userJoinedChannel(string userName, string channel)
        signal userLeftChannel(string userName, string channel)
        signal onlineUsersUpdated(var userList)

        // Sinais de notificação
        signal notificationTriggered(string title, string message, string type)
        signal userMentioned(string channel, string userName, string message)

        // Sinais de conexão
        signal connectionStatusChanged(bool connected)
        signal connectionError(string errorMessage)

        // Sinais de UI
        signal loadingStateChanged(string component, bool isLoading)
        signal showUserProfile(string userName)
        signal showChannelSettings(string channelName)

        // Helper para emitir mensagem
        function emitMessageReceived(channel, sender, message, messageType, timestamp) {
            var now = timestamp || new Date()
            var messageData = {
                sender: sender,
                message: message,
                messageType: messageType || "other",
                timestamp: now.toISOString(),
                displayDate: now.toLocaleDateString(undefined, {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit'
                }),
                displayTime: now.toLocaleTimeString(undefined, {
                    hour: '2-digit',
                    minute: '2-digit'
                })
            }
            messageReceived(channel, messageData)
        }

        // Helper para notificação
        function notify(title, message, type) {
            type = type || "info"
            notificationTriggered(title, message, type)
        }

        // Log de debug
        property bool debugMode: true

        function log(message, data) {
            if (debugMode) {
                console.log("[EventBus]", message, data ? JSON.stringify(data) : "")
            }
        }
    }

    // ==================== Conexões com Backend ====================

    Component.onCompleted: {
        // DEBUG: Verifica se eventBus existe
        console.log("=== DEBUG EVENTBUS ===")
        console.log("eventBus existe?", typeof eventBus)
        console.log("eventBus.log existe?", typeof eventBus.log)
        console.log("=====================")

        // Conecta sinais do backend Python ao eventBus QML
        if (typeof backend !== 'undefined') {
            // Mensagem recebida do servidor
            backend.messageReceivedFromServer.connect(function(channel, messageData) {
                eventBus.messageReceived(channel, messageData)
            })

            // Status de usuário mudou
            backend.userStatusChangedFromServer.connect(function(userName, status) {
                eventBus.userStatusChanged(userName, status)
            })

            // Histórico de canal recebido
            backend.channelHistoryReceived.connect(function(channel, messages) {
                eventBus.channelHistoryLoaded(channel, messages)
            })

            // Status de conexão mudou (Backend → EventBus)
            backend.connectionStatusChanged.connect(function(connected) {
                eventBus.connectionStatusChanged(connected)
                if (connected) {
                    eventBus.notify("Conectado", "Conectado ao servidor IRC", "success")
                } else {
                    eventBus.notify("Desconectado", "Conexão perdida", "error")
                }
            })

            // Erro ocorreu
            backend.errorOccurred.connect(function(errorMessage) {
                eventBus.connectionError(errorMessage)
                eventBus.notify("Erro", errorMessage, "error")
            })

            eventBus.log("Backend conectado ao EventBus")
        } else {
            // Backend não disponível - modo de desenvolvimento
            eventBus.log("Rodando sem backend (modo dev)")
            connectionBar.isConnected = false
            connectionBar.statusMessage = "Modo Desenvolvimento"
        }

        // Conecta EventBus à UI
        eventBus.connectionStatusChanged.connect(function(connected) {
            connectionBar.isConnected = connected
            connectionBar.statusMessage = connected ? "Conectado" : "Desconectado"
        })

        eventBus.connectionError.connect(function(errorMessage) {
            connectionBar.statusMessage = "Erro: " + errorMessage
        })

        // Conecta EventBus para chamar backend quando necessário
        eventBus.channelSelected.connect(function(channelName) {
            if (typeof backend !== 'undefined') {
                backend.loadChannelHistory(channelName)
            }
        })

        eventBus.messageReceived.connect(function(channel, messageData) {
            // Se for mensagem do próprio usuário, envia para servidor
            if (messageData.messageType === "self" && typeof backend !== 'undefined') {
                backend.sendMessage(channel, messageData.message)
            }
        })
    }

    // ==================== UI ====================

    Rectangle {
        anchors.fill: parent
        color: "#1E1E2E"

        // Barra de status de conexão
        Rectangle {
            id: connectionBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            visible: true

            // Estado interno da barra
            property bool isConnected: false
            property string statusMessage: "Desconectado"

            color: isConnected ? "#47f063" : "#f04747"

            Label {
                anchors.centerIn: parent
                text: connectionBar.isConnected
                      ? "🟢 " + connectionBar.statusMessage
                      : "🔴 " + connectionBar.statusMessage
                color: "white"
                font.bold: true
            }

            Behavior on color {
                ColorAnimation { duration: 300 }
            }
        }

        SplitView {
            id: mainSplitView
            anchors.top: connectionBar.visible ? connectionBar.bottom : parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            // Lista de Canais
            ChannelList {
                id: channelList
                SplitView.preferredWidth: 180
                SplitView.minimumWidth: 100
            }

            // Área de Chat
            ChatArea {
                id: chatArea
                SplitView.fillWidth: true
                SplitView.minimumWidth: 300
            }

            // Lista de Usuários
            UserList {
                id: userList
                SplitView.preferredWidth: 150
                SplitView.minimumWidth: 130
            }
        }
    }

    // ==================== Sistema de Notificações ====================

    Popup {
        id: notificationPopup
        x: parent.width - width - 20
        y: 20
        width: 300
        height: notificationContent.implicitHeight + 40
        modal: false
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: "#2C2C3F"
            radius: 8
            border.color: notificationPopup.notificationType === "error" ? "#f04747" :
                          notificationPopup.notificationType === "success" ? "#47f063" :
                          notificationPopup.notificationType === "warning" ? "#faa61a" : "#00C8FF"
            border.width: 2
        }

        property string notificationTitle: ""
        property string notificationMessage: ""
        property string notificationType: "info"

        ColumnLayout {
            id: notificationContent
            anchors.fill: parent
            anchors.margins: 20
            spacing: 8

            Label {
                text: notificationPopup.notificationTitle
                color: "white"
                font.bold: true
                font.pixelSize: 14
                Layout.fillWidth: true
            }

            Label {
                text: notificationPopup.notificationMessage
                color: "#b9bbbe"
                font.pixelSize: 12
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }

        Timer {
            id: notificationTimer
            interval: 3000
            onTriggered: notificationPopup.close()
        }

        onOpened: notificationTimer.start()
    }

    // Conecta notificações ao EventBus
    Connections {
        target: eventBus

        function onNotificationTriggered(title, message, type) {
            notificationPopup.notificationTitle = title
            notificationPopup.notificationMessage = message
            notificationPopup.notificationType = type
            notificationPopup.open()
        }
    }

    // ==================== Debug Console ====================

    // Descomente para ver logs em tempo real
    /*
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        color: "#1a1a1a"

        ListView {
            id: debugConsole
            anchors.fill: parent
            anchors.margins: 5
            clip: true

            model: ListModel {
                id: debugModel
            }

            delegate: Text {
                text: model.message
                color: "#00ff00"
                font.family: "Courier"
                font.pixelSize: 10
            }
        }
    }

    Connections {
        target: EventBus

        function onChannelSelected(channelName) {
            debugModel.append({message: "[EventBus] Canal: " + channelName})
        }

        function onMessageReceived(channel, messageData) {
            debugModel.append({message: "[EventBus] MSG em " + channel})
        }
    }
    */
}
