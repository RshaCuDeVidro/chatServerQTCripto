
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels // Added this import as it's present in the provided "Code Edit" and might be needed for Connections or other elements.

StyledSidebar {
    id: root
    title: "USUÁRIOS"

    // ==================== CONEXÕES BACKEND ====================
    Connections {
        target: backend
        
        function onUserListUpdated(users) {
            userListModel.clear()
            for (var i = 0; i < users.length; i++) {
                userListModel.append({
                    "name": users[i],
                    "statusColor": "#a6e3a1" // Online
                })
            }
        }
    }

    ListModel {
        id: userListModel
        // Dummy data removed as per instruction
    }

    // ==================== UI ====================

    ListView {
        id: userView
        anchors.fill: parent
        anchors.topMargin: 8
        clip: true
        reuseItems: true
        boundsBehavior: Flickable.StopAtBounds
        model: userListModel
        spacing: 4

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
            id: userDelegate
            width: userView.width - 16
            anchors.horizontalCenter: parent.horizontalCenter
            height: 40
            
            background: Rectangle {
                radius: 6
                color: userDelegate.hovered ? "#313244" : "transparent"
            }

            contentItem: RowLayout {
                spacing: 10
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                Label {
                    text: model.name
                    color: userDelegate.hovered ? "#ffffff" : "#bac2de"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

