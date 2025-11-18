import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

StyledSidebar {
    id: root
    title: "Usuários Online"

    // ==================== CONFIGURAÇÃO DE STATUS ====================

    readonly property var statusInfo: ({
        "online":  { color: "#47f063", label: "Online" },
        "away":    { color: "#faa61a", label: "Ausente" },
        "offline": { color: "#747f8d", label: "Offline" }
    })


    ListModel {
        id: userListModel

    }

    // ==================== MUDANÇA: Escuta EventBus ====================

    Component.onCompleted: {
        // Quando status de usuário muda
        eventBus.userStatusChanged.connect(function(userName, status) {
            updateUserStatus(userName, status)
            eventBus.log("UserList: Status atualizado", {user: userName, status: status})
        })

        // Quando usuário entra em canal
        eventBus.userJoinedChannel.connect(function(userName, channel) {
            // Adiciona usuário se não existir
            var exists = findUserIndex(userName) !== -1

            if (!exists) {
                addUser(userName, "online")
                eventBus.log("UserList: Usuário adicionado", userName)
            } else {
                updateUserStatus(userName, "online")
            }
        })

        // Quando usuário sai do canal
        eventBus.userLeftChannel.connect(function(userName, channel) {
            updateUserStatus(userName, "offline")
            eventBus.log("UserList: Usuário saiu", userName)
        })

        // Quando lista completa de usuários online é recebida
        eventBus.onlineUsersUpdated.connect(function(userList) {
            loadUserList(userList)
            eventBus.log("UserList: Lista completa carregada", userList.length + " users")
        })
    }

    // ==================== FUNÇÕES PÚBLICAS ====================

    function updateUserStatus(userName, newStatus) {
        var index = findUserIndex(userName)

        if (index !== -1) {
            userListModel.setProperty(index, "status", newStatus)
        }
    }

    function addUser(userName, status) {
        // Verifica se já existe
        if (findUserIndex(userName) !== -1) {
            return
        }

        userListModel.append({
            name: userName,
            status: status || "online"
        })
    }

    function removeUser(userName) {
        var index = findUserIndex(userName)

        if (index !== -1) {
            userListModel.remove(index)
        }
    }

    function loadUserList(userList) {
        userListModel.clear()

        for (var i = 0; i < userList.length; i++) {
            var user = userList[i]//
            addUser(user.username || user.name, user.status || "online")
            //addUser(userList[i].name, userList[i].status)
        }
    }

    function clearUsers() {
        userListModel.clear()
    }

    // ==================== FUNÇÕES AUXILIARES ====================

    function findUserIndex(userName) {
        for (var i = 0; i < userListModel.count; i++) {
            if (userListModel.get(i).name === userName) {
                return i
            }
        }
        return -1
    }

    function countUsersByStatus(status) {
        var count = 0
        for (var i = 0; i < userListModel.count; i++) {
            if (userListModel.get(i).status === status) {
                count++
            }
        }
        return count
    }

    function getStatusColor(statusString) {
        return statusInfo[statusString] ? statusInfo[statusString].color : statusInfo.offline.color
    }

    function getStatusLabel(statusString) {
        return statusInfo[statusString] ? statusInfo[statusString].label : statusString
    }

    // ==================== UI ====================

    ListView {
        id: userView
        anchors.fill: parent
        spacing: 3
        clip: true
        reuseItems: true
        boundsBehavior: Flickable.StopAtBounds
        model: userListModel

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 8
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Rectangle {
                radius: 4
                color: "#37FF00"
            }
        }

        section.property: "status"
        section.criteria: ViewSection.FullString

        section.delegate: Rectangle {
            width: userView.width
            height: 30
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: root.getStatusColor(section)
                }

                Label {
                    text: root.getStatusLabel(section)
                    color: "#b9bbbe"
                    font.pixelSize: 11
                    font.bold: true
                    Layout.fillWidth: true
                }

                Label {
                    text: root.countUsersByStatus(section)
                    color: "#72767d"
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        delegate: ItemDelegate {
            width: userView.width
            height: 28
            clip: true
            opacity: model.status === "offline" ? 0.6 : 1.0

            background: Rectangle {
                radius: 8
                color: "transparent"
            }

            contentItem: RowLayout {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 8

                Rectangle {
                    width: 5
                    height: 5
                    radius: 2.5
                    color: root.getStatusColor(model.status)
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: model.name
                    color: "#b9bbbe"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
