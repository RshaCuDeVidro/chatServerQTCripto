import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: mainWindow
    visible: true
    minimumWidth: 900
    minimumHeight: 600
    width: 1100
    height: 700
    title: "IRC Chat"
    color: "#1e1e2e" // Base dark color

    // ================== TELA DE CHAT ====================

    Item {
        id: mainContent
        anchors.fill: parent
        opacity: 0
        y: 20

        // Conectar ao backend ao iniciar
        Component.onCompleted: {
            startupAnim.start()
            var randomId = Math.floor(Math.random() * 1000)
            backend.connectToServer("User" + randomId)
        }

        ParallelAnimation {
            id: startupAnim
            NumberAnimation { target: mainContent; property: "opacity"; to: 1; duration: 800; easing.type: Easing.OutCubic }
            NumberAnimation { target: mainContent; property: "y"; to: 0; duration: 800; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            // Barra de status / Topo
            Rectangle {
                id: topBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 48
                color: "#181825" // Mantle
                
                // Linha separadora sutil
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#313244" // Surface0
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    Label {
                        text: "Chatzin"
                        color: "#cba6f7" // Mauve
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "Segoe UI"
                    }

                    Item { Layout.fillWidth: true }

                    
                    Button {
                        text: "Logs"
                        flat: true
                        
                        background: Rectangle {
                            color: parent.hovered ? "#313244" : "transparent"
                            radius: 4
                        }
                        
                        contentItem: Label {
                            text: parent.text
                            color: parent.hovered ? "#cdd6f4" : "#6c7086"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: logView.isOpen = !logView.isOpen
                    }
                }
            }

            SplitView {
                anchors.top: topBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                
                handle: Rectangle {
                    implicitWidth: 1
                    color: "#313244"
                }

                ChannelList {
                    id: channelList
                    SplitView.preferredWidth: 220
                    SplitView.minimumWidth: 180
                    SplitView.maximumWidth: 300
                }

                ChatArea {
                    id: chatArea
                    SplitView.fillWidth: true
                    SplitView.minimumWidth: 400
                    currentChannel: "geral"
                }

                UserList {
                    id: userList
                    currentChannel: chatArea.currentChannel
                    SplitView.preferredWidth: 200
                    SplitView.minimumWidth: 150
                    SplitView.maximumWidth: 250
                }
            }
        }
    }

    // Overlay de Logs
    Rectangle {
        id: overlayDimmer
        anchors.fill: parent
        color: "black"
        opacity: logView.isOpen ? 0.4 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        MouseArea {
            anchors.fill: parent
            onClicked: logView.isOpen = false
        }
    }

    LogView {
        id: logView
        anchors.centerIn: parent
        onClose: isOpen = false
    }
}
