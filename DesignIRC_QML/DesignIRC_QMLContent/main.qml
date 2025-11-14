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
        //color: "#0E0E12"
        // anchors.margins: 7
        // radius: 15

        SplitView{//*/RowLayout {
            anchors.fill: parent
            //spacing: 0

            id:mainSplitView


            ChannelList {
                id:channelList
                // Layout.preferredWidth: 180
                // Layout.fillHeight: true

                SplitView.preferredWidth: 180
                SplitView.minimumWidth: 100
                //SplitView.resizable: true

                onChannelSelected: (channelName) =>{
                    chatArea.currentChannel = channelName
                }
            }


            ChatArea {
                id: chatArea
                // Layout.fillWidth: true
                // Layout.fillHeight: true

                SplitView.fillWidth: true
                SplitView.minimumWidth: 300
                //SplitView.resizable: true
            }


            UserList {
                Layout.preferredWidth: 180
                Layout.fillHeight: true

                SplitView.preferredWidth: 180
                SplitView.minimumWidth: 100
                //SplitView.resizable: true
            }
        }
    }
}
