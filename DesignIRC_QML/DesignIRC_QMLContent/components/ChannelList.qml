import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

StyledSidebar {
    id: root
    title: "Canais"

    //signal channelSelected(string channelName)

    ListModel {
        id: channelListModel
        // ListElement { channelName: "geral" }
        // ListElement { channelName: "dev" }
        //ListElement { channelName: "design" }
        //ListElement { channelName: "aleatorio" }
    }

    // ==================== SINCRONIZAÇÃO ====================
        // Escuta o EventBus para manter a seleção visual correta
    Connections {
        target: eventBus
        function onChannelSelected(channelName) {
                syncSelection(channelName)
        }
    }

    function syncSelection(channelName) {
        for (var i = 0; i < channelListModel.count; i++) {
            if (channelListModel.get(i).channelName === channelName) {
                channelView.currentIndex = i
                return
            }
            }
        // Se não encontrar (ex: na inicialização antes da lista carregar), ignora
        channelView.currentIndex = -1
    }

    Component.onCompleted: {
        console.log("[ChannelList] Componente carregado")

        // Escuta quando backend enviar lista de canais
        if (typeof backend !== 'undefined') {
            backend.channelsListReceived.connect(function(channelList) {
                console.log("[ChannelList] Recebendo", channelList.length, "canais do servidor")

                // Limpa lista atual
                channelListModel.clear()

                // Preenche com canais do servidor
                for (var i = 0; i < channelList.length; i++) {
                     var channel = channelList[i]
                    channelListModel.append({
                        "channelName": channel.name
                    })
                 }
                if (typeof appCoordinator !== 'undefined') {
                    syncSelection(appCoordinator.currentChannel)
                }
            })

            // Requisita lista de canais
            backend.requestChannelsList()
        }
    }

    // ==================== UI ====================

    ListView {
        id: channelView
        anchors.fill: parent
        clip: true
        spacing: 6
        boundsBehavior: Flickable.StopAtBounds
        model: channelListModel
        reuseItems: true

        currentIndex: -1

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

        delegate: ItemDelegate {
            id: channelDelegate
            width: channelView.width
            height: 45
            checkable: true
            checked: ListView.isCurrentItem
            clip: true

            background: Rectangle {
                radius: 8
                color: checked ? "#252535" : "transparent"
                Rectangle {
                    anchors.fill: parent
                    color: "#40444b"
                    opacity: channelDelegate.hovered && !channelDelegate.checked ? 0.5 : 0.0

                    Behavior on opacity {
                        NumberAnimation {duration: 100}
                    }
                }
            }

            contentItem: RowLayout {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8

                Label {
                    text: "#" + model.channelName
                    color: channelDelegate.checked ? "white" : "#8B8DA3"
                    font.pixelSize: 16
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }

                // Rectangle {
                //     width: 22
                //     height: 22
                //     radius: 11
                //     color: "#f04747"
                //     visible: model.unreadCount > 0

                //     Label {
                //         anchors.centerIn: parent
                //         text: model.unreadCount > 99 ? "99+" : model.unreadCount
                //         color: "white"
                //         font.pixelSize: model.unreadCount > 99 ? 9 : 12
                //         font.bold: true
                //     }
                // }
            }

            onClicked: {
                channelView.currentIndex = index

                // Não precisa mais emitir signal local
                // Apenas notifica via EventBus
                eventBus.channelSelected(model.channelName)


                //resetUnread(model.channelName)
            }
        }
    }
}
