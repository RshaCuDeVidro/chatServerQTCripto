import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    visible: true
    minimumWidth: 800
    minimumHeight: 600
    width: 1000
    height: 600
    title: "IRC das Putas"

    Rectangle {
        anchors.fill: parent
        color: "#0E0E12"
        // anchors.margins: 7
        // radius: 15

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // Lista de canais
            ChannelList {
                id:channelList
                Layout.preferredWidth: 180
                Layout.fillHeight: true

                onChannelSelected: (channelName) =>{
                    chatArea.currentChannel = channelName
                }
            }

            // Área central do chat
            ChatArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Lista de usuários
            UserList {
                Layout.preferredWidth: 180
                Layout.fillHeight: true
            }
        }
    }
}
