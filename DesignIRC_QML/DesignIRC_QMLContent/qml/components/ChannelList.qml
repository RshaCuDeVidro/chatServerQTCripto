import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#202225"

        ColumnLayout {
            anchors.fill: parent
            activeFocusOnTab: true
            spacing: 8

            Label {
                text: "Canais"
                color: "#b9bbbe"
                font.pixelSize: 16
                font.bold: true
            }

            ListView {
                id: channelView
                synchronousDrag: true
                boundsMovement: Flickable.FollowBoundsBehavior
                boundsBehavior: Flickable.StopAtBounds
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model:ListModel{
                    id: channelModel
                    ListElement{name: "general"}
                    ListElement{name:  "crime"}


                }


                ScrollBar.vertical: ScrollBar{
                     policy: ScrollBar.AsNeeded
                }


                delegate: ItemDelegate {
                    width: parent.width
                    height: 40
                    //color: hovered ? "#393c43" : "transparent"
                    text: model.name

                    background: Rectangle{
                        color: highlighted ? "#393c43" : "transparent"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: white
                        font: parent.font
                        anchors.centerIn: parent
                    }

                    onClicked: channelView.currentIndex = index
                }

                Component.onCompleted: currentIndex = 0
            }
        }

}
