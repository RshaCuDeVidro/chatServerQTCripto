import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//import QtQuick.Studio.DesignEffects
import QtQuick.Effects

Rectangle {
    id: channelList
    color: "#2f3136"
    //radius: 10
    //Layout.fillHeight: true
    //Layout.fillWidth: true

    signal channelSelected(string name)
    //não uso
    // DesignEffect {
    //     visible: true
    //     effects: [
    //         DesignDropShadow {
    //             color: "#C800FF"
    //             showBehind: false
    //             offsetX: 0
    //             offsetY: 2
    //             blur: 20
    //         },
    //         DesignInnerShadow {
    //             color: "#C800FF"
    //             showBehind: false
    //             offsetY: 1
    //             blur: 20
    //         }
    //     ]
    // }

    // ===========================
    // Modelo de canais (embutido)
    // ===========================
    ListModel {
        id: channelListModel
        ListElement { channelName: "geral"; unreadCount: 3 }
        ListElement { channelName: "dev"; unreadCount: 0 }
        ListElement { channelName: "design"; unreadCount: 10 }
        ListElement { channelName: "aleatorio"; unreadCount: 0 }
        ListElement { channelName: "testes"; unreadCount: 0 }
        ListElement { channelName: "offtopic"; unreadCount: 0 }
        ListElement { channelName: "uiux"; unreadCount: 1 }
        ListElement { channelName: "backend"; unreadCount: 0 }
        ListElement { channelName: "geral"; unreadCount: 3 }
        ListElement { channelName: "dev"; unreadCount: 0 }
        ListElement { channelName: "design"; unreadCount: 10 }
        ListElement { channelName: "aleatorio"; unreadCount: 0 }
        ListElement { channelName: "testes"; unreadCount: 0 }
        ListElement { channelName: "Sal de aula"; unreadCount: 0 }
        ListElement { channelName: "design 2"; unreadCount: 1 }
        ListElement { channelName: "aleatorio"; unreadCount: 0 }
        ListElement { channelName: "testes"; unreadCount: 0 }
        ListElement { channelName: "dev"; unreadCount: 0 }
        ListElement { channelName: "design"; unreadCount: 1 }
        ListElement { channelName: "aleatorio"; unreadCount: 5 }
        ListElement { channelName: "testes"; unreadCount: 10 }
        ListElement { channelName: "design"; unreadCount: 1 }
        ListElement { channelName: "design"; unreadCount: 1 }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // DesignEffect {
        //     visible: true
        //     effects: [
        //         DesignDropShadow {
        //             color: "#C800FF"
        //             showBehind: true
        //             offsetX: 0
        //             offsetY: 2
        //             blur: 20
        //         },
        //         DesignInnerShadow {
        //             color: "#C800FF"
        //             showBehind: false
        //            offsetY: 1
        //             blur: 20
        //         }
        //     ]
        // }

        Label {
            text: "Canais"
            color: "#E0E0EB"
            font.pixelSize: 18
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Rectangle {
            id: container
            color: "#2C2C3F"
            radius: 8
            border.color: "#C800FF"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: channelView
                anchors.fill: parent
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                model: channelListModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    active: true
                    visible: true
                    width: 8
                    background: Rectangle { color: "transparent" }
                    contentItem: Rectangle {
                        radius: 4
                        color: "#C800FF"
                    }
                }

                delegate: ItemDelegate {
                    width: channelView.width
                    height: 44
                    checkable: true
                    checked: ListView.isCurrentItem


                    background: Rectangle {
                        radius: 6
                        color: checked ? "#4f545c" : "transparent"
                        Rectangle {
                            anchors.fill: parent
                            color: "#40444b"
                            opacity: hovered && !checked ? 0.5 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 100 } }
                        }
                    }

                    contentItem: RowLayout {
                        spacing: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            text: "#" + model.channelName
                            color: checked ? "white" : "#b9bbbe"
                            font.pixelSize: 16
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        //  mensagens não lidas
                        Rectangle {
                            width: 22
                            height: 22
                            radius: 11
                            color: "#f04747"
                            visible: model.unreadCount > 0

                            Label {
                                anchors.centerIn: parent
                                text: model.unreadCount
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }

                    onClicked: {
                        channelView.currentIndex = index
                        channelList.channelSelected(model.channelName)
                    }
                }
            }
        }
    }
}
