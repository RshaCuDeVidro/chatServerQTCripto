import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Rectangle {
    color: "#2A2B38"
    //color: "#2e3035"
    Layout.preferredWidth: 240

    // 1. Defina as cores como um objeto (mapa)
    readonly property var statusColors: {
        "online": "#47f063",
        "away": "#faa61a",
        "offline": "#747f8d"
    }

    // 2. Sua função fica muito mais simples
    function getStatusColor(statusString) {
        // Retorna a cor do mapa,
        // ou a cor 'offline' como padrão se não encontrar
        return statusColors[statusString] || statusColors.offline;
    }

    // Rectangle {
    //     anchors.fill: parent
    //     anchors.margins: 10
    //     color: "transparent"
    ListModel{
        id: userListModel

        ListElement{name: "User1"; status: "online"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status: "offline"}
        ListElement{name: "User1"; status: "offline"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status: "offline"}
        ListElement{name: "User1"; status: "online"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status:"offline"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status: "online"}
        ListElement{name: "User1"; status:"offline"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status:"offline"}
        ListElement{name: "User1"; status: "online"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status:"online"}
        ListElement{name: "User1"; status:"online"}

        ListElement{name: "User1"; status: "offline"}
        ListElement{name: "User1"; status:"away"}
        ListElement{name: "User1"; status:"away"}
        ListElement{name: "User1"; status: "offline"}
        ListElement{name: "User1"; status:"away"}
    }


    ColumnLayout {
        id: columnUserLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

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
            clip: false

            RectangularShadow{
                color: "#C800FF"
                anchors.fill: parent
                z: -1

                blur: 14
                radius: 8
                spread: 4
                cached: true

                PropertyAnimation on blur{
                    easing.bezierCurve: [0.42,0,0.58,1]
                    running: true
                    loops: -1

                    from: 18
                    to: 14
                    duration: 1500
                }

                PropertyAnimation on spread {
                    easing.bezierCurve: [0.42,0,0.58,1]
                    running: true
                    loops: -1


                    from: 7
                    to: 4
                    duration: 1500
                }  //fim animação

            }


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
                    //visible: userView.contentHeight > userView.height
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

                    opacity: model.status === "offline" ? 0.6 : 1.0

                        //width: parent.width
                    background: Rectangle{
                        radius: 8
                        color: highlighted ? "#40444b" : "transparent"
                    }

                    contentItem: RowLayout {
                        spacing: 8
                        anchors.verticalCenter: parent.verticalCenter                            // text: parent.text
                        // font: parent.font
                        // verticalAlignment: Text.AlignVCenter

                        Rectangle{
                            width: 5
                            height: 5
                            radius: 11
                            color: getStatusColor(model.status)
                            Layout.alignment: Qt.AlignVCenter

                            // SequentialAnimation on opacity {
                            //     running: model.status === "online"
                            //     loops: Animation.Infinite
                            //     NumberAnimation { from: 1; to: 0.4; duration: 700; easing.type: Easing.InOutQuad }
                            //     NumberAnimation { from: 0.4; to: 1; duration: 700; easing.type: Easing.InOutQuad }
                            // }

                        }

                        Label{
                            text: model.name
                            color: highlighted ? "white" : "#b9bbbe"
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
