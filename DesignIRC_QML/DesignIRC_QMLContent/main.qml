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
    title: "IRC Chat"

    // ==================== EVENTBUS (SINGLETON) ====================

    property QtObject eventBus: QtObject {
        id: _eventBus
        objectName: "EventBus"

        // ===== EVENTOS DE BACKEND (Backend → Frontend) =====
        signal messageReceived(string channel, var messageData)
        signal channelHistoryLoaded(string channel, var messages)
        signal userStatusChanged(string userName, string status)
        signal userJoinedChannel(string userName, string channel)
        signal userLeftChannel(string userName, string channel)
        signal onlineUsersUpdated(var userList)
        signal connectionStatusChanged(bool connected)
        signal connectionError(string errorMessage)

        // ===== EVENTOS DE UI (Frontend → Frontend) =====
        signal channelSelected(string channelName)
        // signal unreadCountChanged(string channel, int count)
        // signal notificationTriggered(string title, string message, string type)
        // signal userMentioned(string channel, string userName, string message)
        signal loadingStateChanged(string component, bool isLoading)
        signal showUserProfile(string userName)
        signal showChannelSettings(string channelName)

        // ===== HELPERS =====
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

        // Debug
        property bool debugMode: true
        function log(message, data) {
            if (debugMode) {
                console.log("[EventBus]", message, data ? JSON.stringify(data) : "")
            }
        }
    }

    // ==================== ORQUESTRADOR (MEDIATOR) ====================

    QtObject {
        id: appCoordinator

        // Estado da aplicação
        property bool isConnected: false
        property bool isLoggedIn: false
        property string currentUser: ""
        property string currentChannel: "geral"

        // Fluxo: Conexão estabelecida
        function onConnected() {
            isConnected = true
            eventBus.log("Orquestrador: Conectado")
            // eventBus.notify("Conectado", "Servidor alcançado", "success")
        }

        // Fluxo: Login bem-sucedida
        function onLoggedIn(userData) {
            isLoggedIn = true
            currentUser = userData.username

            eventBus.log("Orquestrador: Logado como", currentUser)

            // 1. Requisita lista de usuários online
            if (typeof backend !== 'undefined') {
                backend.requestOnlineUsers()
            }

            // 2. Entra no canal padrão
            Qt.callLater(function() {
                switchChannel(currentChannel)
            })
        }

        // Fluxo: Desconexão
        function onDisconnected() {
            //var wasAuthenticated = isAuthenticated
            var wasLoggedIn = isLoggedIn

            isConnected = false
            isLoggedIn = false
            currentUser = ""

            eventBus.log("Orquestrador: Desconectado")

            // if (wasAuthenticated) {
            //     eventBus.notify("Desconectado", "Conexão perdida", "error")
            // }
        }

        // Fluxo: Troca de canal
        function switchChannel(channelName) {
            if (!isLoggedIn) {
                //eventBus.notify("Erro", "Você precisa estar autenticado", "error")
                return
            }

            eventBus.log("Orquestrador: Trocando para", channelName)

            var oldChannel = currentChannel
            currentChannel = channelName

            // Backend sai do canal anterior e entra no novo
            if (typeof backend !== 'undefined') {
                backend.joinChannel(channelName)
            }

            // EventBus notifica componentes
            //eventBus.channelSelected(channelName)
        }

        // Fluxo: Enviar mensagem
        function sendMessage(channel, message) {
            if (!isLoggedIn) {
                //eventBus.notify("Erro", "Você precisa estar autenticado", "error")
                return
            }

            // Backend + UI local (otimista)
            if (typeof backend !== 'undefined') {
                backend.sendMessage(channel, message)

                //Adiciona localmente
                eventBus.emitMessageReceived(
                    channel,
                    currentUser,
                    message,
                    "self",
                    new Date()
                )
            } else {
                // Modo offline
                eventBus.emitMessageReceived(
                    channel,
                    "Você",
                    message,
                    "self",
                    new Date()
                )
            }
        }
    }

    // ==================== CONEXÕES BACKEND → ORQUESTRADOR ==================== 
    Component.onCompleted: {
        console.log("=== INICIANDO APLICAÇÃO ===")

        if (typeof backend !== 'undefined') {
            console.log("✅ Backend disponível")

            // Backend → Orquestrador
            backend.connectionStatusChanged.connect(function(connected) {
                if (connected) {
                    appCoordinator.onConnected()
                } else {
                    appCoordinator.onDisconnected()
                }
                eventBus.connectionStatusChanged(connected)
            })

            backend.loginSuccess.connect(function(userData) {
                appCoordinator.onLoggedIn(userData)
            })

            backend.loginFailed.connect(function(errorMessage) {
                eventBus.notify("Erro de Autenticação", errorMessage, "error")
            })

            // Backend → EventBus (direto)
            backend.messageReceived.connect(eventBus.messageReceived)
            backend.channelHistoryReceived.connect(eventBus.channelHistoryLoaded)
            backend.userStatusChanged.connect(eventBus.userStatusChanged)
            backend.userJoinedChannel.connect(eventBus.userJoinedChannel)
            backend.userLeftChannel.connect(eventBus.userLeftChannel)
            backend.usersListUpdated.connect(eventBus.onlineUsersUpdated)
            backend.errorOccurred.connect(function(errorMessage) {
                eventBus.connectionError(errorMessage)
            })

            console.log("✅ Backend conectado")

        } else {
            console.warn("⚠️ Modo desenvolvimento (sem backend)")
            // Em modo dev, mostra a interface direto
            appCoordinator.isLoggedIn = true
            appCoordinator.currentUser = "DevUser"
        }

        // ===== CONEXÕES EVENTBUS → ORQUESTRADOR =====

        eventBus.channelSelected.connect(function(channelName) {
            appCoordinator.switchChannel(channelName)
        })

        eventBus.messageReceived.connect(function(channel, messageData) {
            if (messageData.messageType === "self") {
                // Já foi processado
            }
        })

        console.log("=== APLICAÇÃO INICIADA ===")
    }

    // ================== STACK VIEW (Login/Chat) ================

    StackView {
        id: mainStack
        anchors.fill: parent
        initialItem: loginScreen

        // Mostra chat quando autenticado
        Connections {
            target: appCoordinator
            function onIsLoggedInChanged() {
                if (appCoordinator.isLoggedIn) {
                    mainStack.replace(chatScreen)
                } else {
                    mainStack.replace(loginScreen)
                }
            }
        }
    }

    // ================== TELA DE LOGIN ================

    Component {
        id: loginScreen

        Rectangle {
            color: "#1E1E2E"

            ColumnLayout {
                anchors.centerIn: parent
                width: 400
                spacing: 20

                // Logo/Título
                Label {
                    text: "IRC Chat"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#C800FF"
                    Layout.alignment: Qt.AlignHCenter
                }

                // Status de conexão
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 8
                    color: appCoordinator.isConnected ? "#47f06322" : "#f0474722"
                    border.color: appCoordinator.isConnected ? "#47f063" : "#f04747"
                    border.width: 2

                    Label {
                        anchors.centerIn: parent
                        text: appCoordinator.isConnected
                              ? "🟢 Conectado ao servidor"
                              : "🔴 Conectando..."
                        color: "white"
                        font.pixelSize: 14
                    }

                    // Indicador de loading
                    BusyIndicator {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 24
                        running: !appCoordinator.isConnected
                    }
                }

                // Card de login
                Rectangle {
                    Layout.fillWidth: true
                    height: loginForm.implicitHeight + 40
                    color: "#2C2C3F"
                    radius: 12
                    border.color: "#C800FF"
                    border.width: 2
                    ColumnLayout {
                        id: loginForm
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        // Mensagem de erro
                        Rectangle {
                            id: errorBox
                            Layout.fillWidth: true
                            height: errorLabel.implicitHeight + 20
                            color: "#f0474722"
                            border.color: "#f04747"
                            border.width: 1
                            radius: 6
                            visible: false

                            Label {
                                id: errorLabel
                                anchors.fill: parent
                                anchors.margins: 10
                                text: ""
                                color: "#f04747"
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Username
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Label {
                                text: "Username"
                                color: "#b9bbbe"
                                font.pixelSize: 12
                            }

                            TextField {
                                id: usernameField
                                Layout.fillWidth: true
                                placeholderText: "Digite seu username"
                                color: "white"

                                background: Rectangle {
                                    color: "#40444b"
                                    radius: 6
                                    border.color: usernameField.activeFocus ? "#C800FF" : "#36393f"
                                    border.width: 2
                                }

                                Keys.onReturnPressed: passwordField.forceActiveFocus()


                            }
                        }



                        // Password
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Label {
                                text: "Senha"
                                color: "#b9bbbe"
                                font.pixelSize: 12
                            }

                            TextField {
                                id: passwordField
                                Layout.fillWidth: true
                                placeholderText: "Digite sua senha"
                                echoMode: TextInput.Password
                                color: "white"

                                background: Rectangle {
                                    color: "#40444b"
                                    radius: 6
                                    border.color: passwordField.activeFocus ? "#C800FF" : "#36393f"
                                    border.width: 2
                                }

                                Keys.onReturnPressed: loginButton.clicked()
                            }
                        }

                        // Checkbox de registro
                        CheckBox {
                            id: registerCheckBox
                            text: "Criar nova conta"
                            Layout.alignment: Qt.AlignHCenter

                            contentItem: Label {
                                text: registerCheckBox.text
                                color: "#b9bbbe"
                                leftPadding: registerCheckBox.indicator.width + 8
                                verticalAlignment: Text.AlignVCenter
                            }

                            onCheckedChanged: {
                                errorBox.visible = false
                            }
                        }

                        // Botão de login/registro
                        Button {
                            id: loginButton
                            Layout.fillWidth: true
                            height: 45
                            text: registerCheckBox.checked ? "Registrar" : "Entrar"
                            enabled: appCoordinator.isConnected &&
                                     usernameField.text.length >= 3 &&
                                     passwordField.text.length >= 6

                            background: Rectangle {
                                color: loginButton.enabled
                                       ? (loginButton.hovered ? "#a800d6" : "#C800FF")
                                       : "#40444b"
                                radius: 6

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Label {
                                text: loginButton.text
                                color: loginButton.enabled ? "white" : "#72767d"
                                font.pixelSize: 16
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                errorBox.visible = false

                                if (typeof backend === 'undefined') {
                                    errorLabel.text = "Backend não disponível"
                                    errorBox.visible = true
                                    return
                                }

                                if (usernameField.text.length < 3) {
                                    errorLabel.text = "Username deve ter no mínimo 3 caracteres"
                                    errorBox.visible = true
                                    return
                                }

                                if (passwordField.text.length < 6) {
                                    errorLabel.text = "Senha deve ter no mínimo 6 caracteres"
                                    errorBox.visible = true
                                    return
                                }

                                if (registerCheckBox.checked) {
                                    // Registro
                                    backend.register(
                                        usernameField.text,
                                        passwordField.text,
                                    )
                                } else {
                                    // Login
                                    backend.login(
                                        usernameField.text,
                                        passwordField.text
                                    )
                                }
                            }
                        }
                    }
                }

                // // Versão/Info
                // Label {
                //     text: "v1.0.0 - IRC Chat Client"
                //     color: "#72767d"
                //     font.pixelSize: 10
                //     Layout.alignment: Qt.AlignHCenter
                // }
            }

            // Conexão para mostrar erros
            Connections {
                target: eventBus
                function onConnectionError(errorMessage) {
                    errorLabel.text = errorMessage
                    errorBox.visible = true
                }
            }
        }
    }

    // ==================== TELA DE CHAT ====================

    Component {
        id: chatScreen

        Rectangle {
            color: "#1E1E2E"

            // Barra de status
            Rectangle {
                id: connectionBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 30

                color: appCoordinator.isConnected ? "#47f063" : "#f04747"

                Label {
                    anchors.centerIn: parent
                    text: appCoordinator.isConnected
                          ? "🟢 Conectado - " + appCoordinator.currentUser
                          : "🔴 Desconectado"
                    color: "white"
                    font.bold: true
                }

                // Botão de logout
                Button {
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    height: 20
                    text: "Sair"
                    flat: true

                    contentItem: Label {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 10
                    }

                    onClicked: {
                        if (typeof backend !== 'undefined') {
                            backend.disconnect()
                        }
                        appCoordinator.isLoggedIn = false
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }

            SplitView {
                anchors.top: connectionBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                ChannelList {
                    id: channelList
                    SplitView.preferredWidth: 180
                    SplitView.minimumWidth: 100
                }

                ChatArea {
                    id: chatArea
                    SplitView.fillWidth: true
                    SplitView.minimumWidth: 300
                    currentChannel: appCoordinator.currentChannel
                }

                UserList {
                    id: userList
                    SplitView.preferredWidth: 150
                    SplitView.minimumWidth: 130
                }
            }
        }
    }
}
