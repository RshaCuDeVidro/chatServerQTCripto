import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

StyledSidebar {
    id: root
    title: "Usuários Online"
    //color: "#2A2B38"
    //Layout.preferredWidth: 240


    readonly property var statusInfo: {
            "online":  { color: "#47f063", label: "Online" },
            "away":    { color: "#faa61a", label: "Ausente" },
            "offline": { color: "#747f8d", label: "Offline" }
        }


    function getStatusColor(statusString) {

        return statusColors[statusString] || statusColors.offline
    }

    function countUsersByStatus(status) {
        let count = 0
        for (var i = 0; i < userListModel.count; i++) {
            if (userListModel.get(i).status === status) {
                count++
            }
        }
        return count
    }

    ListModel {
        id: userListModel

        // a gente vai ter que ordenar no python
        // Online
        ListElement { name: "Alice"; status: "online" }
        ListElement { name: "Bob"; status: "online" }
        ListElement { name: "Carlos"; status: "online" }
        ListElement { name: "Gabriel"; status: "online" }
        ListElement { name: "Igor"; status: "online" }
        ListElement { name: "Laura"; status: "online" }

        // Away
        ListElement { name: "Diana"; status: "away" }
        ListElement { name: "Julia"; status: "away" }
        ListElement { name: "Otavio"; status: "away" }
        ListElement { name: "Tiago"; status: "away" }
        ListElement { name: "Wagner"; status: "away" }

        // Offline
        ListElement { name: "Eduardo"; status: "offline" }
        ListElement { name: "Fernanda"; status: "offline" }
        ListElement { name: "Helena"; status: "offline" }
        ListElement { name: "Kevin"; status: "offline" }
        ListElement { name: "Nina"; status: "offline" }
        ListElement { name: "Paula"; status: "offline" }
        ListElement { name: "Vicente"; status: "offline" }
        ListElement { name: "Yara"; status: "offline" }
    }

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
            //visible: userView.contentHeight > userView.height
            width: 8
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Rectangle {
                radius: 4
                color: "#37FF00"
                //color: "#00C8FF"
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
                    //color: getStatusColor(section)
                    color: statusInfo[section] ? statusInfo[section].color : statusInfo.offline.color
                }

                Label {
                    // text: {
                    //     if (section === "online")
                    //         return "Online"
                    //     if (section === "away")
                    //         return "Ausente"
                    //     if (section === "offline")
                    //         return "Offline"
                    //     return section
                    // }
                    text: statusInfo[section] ? statusInfo[section].label : section
                    color: "#b9bbbe"
                    font.pixelSize: 11
                    font.bold: true
                    Layout.fillWidth: true
                }

                Label {
                    text: countUsersByStatus(section)
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

            // anchors.left: parent.left
            // anchors.right: parent.right
            opacity: model.status === "offline" ? 0.6 : 1.0

            //width: parent.width
            background: Rectangle {
                radius: 8
                color: highlighted ? "#40444b" : "transparent"
            }

            contentItem: RowLayout {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter // text: parent.text

                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 8

                Rectangle {
                    width: 5
                    height: 5
                    radius: 11
                    //color: getStatusColor(model.status)
                    color: statusInfo[model.status] ? statusInfo[model.status].color : statusInfo.offline.color
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: model.name
                    color: highlighted ? "white" : "#b9bbbe"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    //Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    //Layout.alignment: Qt.AlignLeft
                }
            }
        }
    }
}
