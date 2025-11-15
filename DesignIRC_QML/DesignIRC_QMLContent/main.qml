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


     // ==================== Conexões com Backend ====================
    Component.onCompleted: {
        // Conecta sinais do backend Python ao EventBus QML
        if (typeof backend !== 'undefined') {
            // Mensagem recebida do servidor
            backend.messageReceivedFromServer.connect(function(channel, messageData) {
                EventBus.messageReceived(channel, messageData)
            })

            // Status de usuário mudou
            backend.userStatusChangedFromServer.connect(function(userName, status) {
                EventBus.userStatusChanged(userName, status)
            })

            // Histórico de canal recebido
            backend.channelHistoryReceived.connect(function(channel, messages) {
                EventBus.channelHistoryLoaded(channel, messages)
            })

            // Status de conexão mudou (Backend → EventBus)
            backend.connectionStatusChanged.connect(function(connected) {
                EventBus.connectionStatusChanged(connected)
                if (connected) {
                    EventBus.notify("Conectado", "Conectado ao servidor IRC", "success")
                } else {
                    EventBus.notify("Desconectado", "Conexão perdida", "error")
                }
            })

            // Erro ocorreu
            backend.errorOccurred.connect(function(errorMessage) {
                EventBus.connectionError(errorMessage)
                EventBus.notify("Erro", errorMessage, "error")
            })

            EventBus.log("Backend conectado ao EventBus")
        } else {
            // Backend não disponível - modo de desenvolvimento
            EventBus.log("Rodando sem backend (modo dev)")
            connectionBar.isConnected = false
            connectionBar.statusMessage = "Modo Desenvolvimento"
        }

        // Conecta EventBus à UI
        EventBus.connectionStatusChanged.connect(function(connected) {
            connectionBar.isConnected = connected
            connectionBar.statusMessage = connected ? "Conectado" : "Desconectado"
        })

        EventBus.connectionError.connect(function(errorMessage) {
            connectionBar.statusMessage = "Erro: " + errorMessage
        })

        // Conecta EventBus para chamar backend quando necessário
        EventBus.channelSelected.connect(function(channelName) {
            if (typeof backend !== 'undefined') {
                backend.loadChannelHistory(channelName)
            }
        })

        EventBus.messageReceived.connect(function(channel, messageData) {
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
            border.color: notificationType === "error" ? "#f04747" :
                          notificationType === "success" ? "#47f063" :
                          notificationType === "warning" ? "#faa61a" : "#00C8FF"
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
        target: EventBus

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
