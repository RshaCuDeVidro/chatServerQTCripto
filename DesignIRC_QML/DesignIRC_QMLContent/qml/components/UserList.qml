import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#2e3035"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            Label {
                text: "Usuários online"
                color: "#b9bbbe"
                font.pixelSize: 16
                font.bold: true
            }

            ListView {
                id: userView
                activeFocusOnTab: true
                boundsMovement: Flickable.FollowBoundsBehavior
                boundsBehavior: Flickable.StopAtBounds
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                reuseItems: true

                model: ListModel{
                    id: userModel
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}
                    ListElement{name: "User1"}

                }


                ScrollBar.vertical: ScrollBar{
                     policy: ScrollBar.AsNeeded
                }


                delegate: ItemDelegate {
                    //width: ListView.view.width
                    width: parent.width
                    height: 28
                    text: model.name
                    background: Rectangle{
                        color: highlighted ? "#40444b" : "transparent"
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        verticalAlignment: Text.AlignVCenter

                    }

                    //color: hovered ? "#3c3f44" : "transparent"

                    onClicked: userView.currentIndex = index

                }
            }
        }
    }
}
