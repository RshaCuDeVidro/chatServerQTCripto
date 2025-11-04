import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Rectangle {
    color: "#2A2B38"
    //color: "#2e3035"
    Layout.preferredWidth: 240

    // Rectangle {
    //     anchors.fill: parent
    //     anchors.margins: 10
    //     color: "transparent"
    ListModel{
        id: userListModel

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


    ColumnLayout {
        id: columnUserLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RectangularShadow{
            color: "#C800FF"
            anchors.fill: container

            blur: 14
            radius: 8
            spread: 4
            cached: true

            PropertyAnimation on blur{
                //easing.bezierCurve: [0.0388,0.452,0.032,1.15,0.0631,1.22,0.112,1.15,0.147,0.892,0.193,0.859,0.236,0.905,0.301,1.08,0.364,1.04,0.45,0.94,0.636,0.997,0.682,1.02,0.746,1.04,0.775,0.99,1,1]
                easing.bezierCurve: [0.42,0,0.58,1]
                //easing.bezierCurve: [0.2,0.2,0.8,0.8,1,1]
                //easing.bezierCurve: [0.25,0.46,0.45,0.94,1,1]


                running: true
                loops: -1

                from: 18
                to: 14
                duration: 1500
            }

            PropertyAnimation on spread {
                easing.bezierCurve: [0.42,0,0.58,1]
                //easing.bezierCurve: [0.0553,0.0385,0.0796,-0.0381,0.109,-0.0381,0.138,-0.0381,0.185,0.0276,0.222,0.00353,0.259,-0.0205,0.332,-0.25,0.385,-0.252,0.462,-0.14,0.543,1.18,0.617,1.24,0.676,1.24,0.738,1,0.778,0.977,0.817,0.953,0.855,1.02,0.889,1.03,0.924,1.03,0.951,0.964,1,1]
                //easing.bezierCurve: [0.257,-0.00742,0.35,0.0559,0.444,0.0517,0.533,0.0539,0.605,-0.0162,0.657,-0.0271,0.741,-0.0118,0.733,0.124,0.776,0.168,0.82,0.131,0.842,-0.0446,0.88,-0.084,0.912,-0.0402,0.955,0.432,1,1]
                running: true
                loops: -1


                from: 7
                to: 4
                duration: 1500
            }  //fim animação

        }
            Label {
                text: "Usuários online"
                color: "#F0F0F5"
                font.pixelSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true



                layer.enabled: true
                layer.effect: DropShadow{
                    color: "#da00c8ff"
                    //color: "#37FF00"
                    radius: 5
                    spread: 0.2
                    transparentBorder: true
                    samples: 10
                    cached: true

                }
            }

            Rectangle{
                id: container
                color: "#2C2C3F"
                radius: 8
                border.color: "#C800FF"
                border.width: 1.5
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true


                ListView {
                    id: userView
                    anchors.fill: parent
                    spacing: 3
                    clip: true
                    reuseItems: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: userListModel

                    ScrollBar.vertical: ScrollBar{
                         policy: ScrollBar.AsNeeded
                         active: true
                         visible: true
                         width: 8
                         background: Rectangle{
                            color: "transparent"
                        }
                         contentItem: Rectangle{
                             radius: 4
                             color: "#37FF00"
                             //color: "#00C8FF"
                         }
                    }


                    delegate: ItemDelegate {
                        //width: ListView.view.width
                        height: 28
                        clip: true
                        anchors.left: parent.left
                        anchors.right: parent.right

                        //width: parent.width
                        background: Rectangle{
                            radius: 8
                            color: highlighted ? "#40444b" : "transparent"
                        }

                        contentItem: RowLayout {
                            spacing: 8
                            anchors.verticalCenter: parent.verticalCenter
                            // text: parent.text
                            // font: parent.font
                            // verticalAlignment: Text.AlignVCenter

                            Rectangle{
                                width: 5
                                height: 5
                                radius: 11
                                color: "#47f063"
                                Layout.alignment: Qt.AlignVCenter

                            }

                            Label{
                                text: model.name
                                color: checked ? "white" : "#b9bbbe"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                //Layout.fillHeight: true
                                Layout.alignment: Qt.AlignVCenter
                            }


                        }

                        //color: hovered ? "#3c3f44" : "transparent"

                        onClicked:{

                            userView.currentIndex = index
                        }
                    }
                }
            }
        }
}
