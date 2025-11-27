import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

StyledSidebar {
    id: root
    title: "CANAIS"

    ListModel {
        id: channelListModel
        ListElement { channelName: "geral" }
        ListElement { channelName: "desenvolvimento" }
        ListElement { channelName: "design" }
        ListElement { channelName: "off-topic" }
    }

    // ==================== UI ====================

    ListView {
        id: channelView
        anchors.fill: parent
        anchors.topMargin: 8
        clip: true
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds
        model: channelListModel
        reuseItems: true

        currentIndex: 0

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 6
            background: Rectangle { color: "transparent" }
            contentItem: Rectangle {
                radius: 3
                color: "#45475a"
            }
        }

        delegate: ItemDelegate {
            id: channelDelegate
            width: channelView.width - 16 // Margem lateral
            anchors.horizontalCenter: parent.horizontalCenter
            height: 36
            checkable: true
            checked: ListView.isCurrentItem
            
            background: Rectangle {
                radius: 6
                color: checked ? "#313244" : (channelDelegate.hovered ? "#313244" : "transparent")
                opacity: checked ? 1.0 : (channelDelegate.hovered ? 0.5 : 1.0)
            }

            contentItem: RowLayout {
                spacing: 8
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Label {
                    text: "#"
                    color: "#6c7086" // Overlay0
                    font.pixelSize: 16
                    font.bold: true
                }

                Label {
                    text: model.channelName
                    color: channelDelegate.checked ? "#ffffff" : "#bac2de" // Text or Subtext1
                    font.pixelSize: 14
                    font.bold: channelDelegate.checked
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            onClicked: {
                channelView.currentIndex = index
                backend.joinChannel(model.channelName)
            }
        }
    }

    Connections {
        target: backend
        function onChannelJoined(channelName) {
            var exists = false;
            for(var i=0; i<channelListModel.count; i++) {
                if(channelListModel.get(i).channelName === channelName) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                channelListModel.append({channelName: channelName})
            }
        }
        
        function onChannelLeft(channelName) {
            for(var i=0; i<channelListModel.count; i++) {
                if(channelListModel.get(i).channelName === channelName) {
                    channelListModel.remove(i);
                    break;
                }
            }
        }
    }
}
