import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

StyledSidebar {
    id: root
    title: "Canais"

    signal channelSelected(string channelName)

    ListModel {
        id: channelListModel
        ListElement { channelName: "geral"; unreadCount: 3 }
                ListElement { channelName: "dev"; unreadCount: 100 }
                ListElement { channelName: "design"; unreadCount: 10 }
                ListElement { channelName: "aleatorio"; unreadCount: 0 }
                ListElement { channelName: "testes"; unreadCount: 0 }
                ListElement { channelName: "offtopic"; unreadCount: 0 }
                ListElement { channelName: "uiux"; unreadCount: 1 }
                ListElement { channelName: "backend"; unreadCount: 0 }
                ListElement { channelName: "frontend"; unreadCount: 5 }
                ListElement { channelName: "mobile"; unreadCount: 2 }
                ListElement { channelName: "database"; unreadCount: 0 }
                ListElement { channelName: "devops"; unreadCount: 0 }
                ListElement { channelName: "sala-de-aula"; unreadCount: 0 }
                ListElement { channelName: "projetos"; unreadCount: 7 }
                ListElement { channelName: "musica"; unreadCount: 0 }
                ListElement { channelName: "games"; unreadCount: 3 }
    }

    Component.onCompleted: {
            eventBus.unreadCountChanged.connect(function(channel, count) {
                root.updateUnreadCount(channel, count)
            })
        }

    // Função para encontrar e atualizar canal
    function updateUnreadCount(channelName, count) {
        for (var i = 0; i < channelListModel.count; i++) {
            if (channelListModel.get(i).channelName === channelName) {
                channelListModel.setProperty(i, "unreadCount", count)
                break
            }
        }
    }

    ListView {
        id: channelView
        anchors.fill: parent
        clip: true
        spacing: 6
        boundsBehavior: Flickable.StopAtBounds
        model: channelListModel
        reuseItems: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 8
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Rectangle {
                radius: 4
                //color: "#00C8FF"
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

                //Layout.fillWidth: true
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

                //  mensagens não lidas
                Rectangle {
                    width: 22
                    height: 22
                    radius: 11
                    color: "#f04747"
                    //color: "#FF3030"
                    visible: model.unreadCount > 0

                    Label {
                        anchors.centerIn: parent
                        text: model.unreadCount > 99 ? "99+" : model.unreadCount
                        color: "white"
                        font.pixelSize: model.unreadCount > 99 ? 9 : 12
                        font.bold: true
                    }
                }
            }

            onClicked: {
                channelView.currentIndex = index
                // Emite via EventBus
                eventBus.channelSelected(model.channelName)
                eventBus.log("Canal selecionado:", model.channelName)

                // Também emite o signal local (compatibilidade)
                root.channelSelected(model.channelName)
            }
        }
    }
    //}
    //}
}
