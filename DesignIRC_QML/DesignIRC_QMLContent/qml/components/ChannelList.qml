import QtQuick 6.8
import QtQuick.Controls as QC
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    color: "#1A1A2E"
    //"#202225"
    ListModel {
        id: channelListModel
        ListElement { channelName: "geral"; unreadCount: 3 }
        ListElement { channelName: "dev"; unreadCount: 0 }
        ListElement { channelName: "design"; unreadCount: 10 }
        ListElement { channelName: "aleatorio"; unreadCount: 0 }
        ListElement { channelName: "testes"; unreadCount: 0 }
        ListElement { channelName: "Sal de aula"; unreadCount: 0 }
        ListElement { channelName: "design 2"; unreadCount: 1 }
        ListElement { channelName: "aleatorio"; unreadCount: 0 }
        ListElement { channelName: "testes"; unreadCount: 0 }
        ListElement { channelName: "dev"; unreadCount: 0 }
        ListElement { channelName: "design"; unreadCount: 1 }
        ListElement { channelName: "aleatorio"; unreadCount: 5 }
        ListElement { channelName: "testes"; unreadCount: 10 }
        ListElement { channelName: "design"; unreadCount: 1 }
        ListElement { channelName: "design"; unreadCount: 1 }
    }


    ColumnLayout {
        anchors.fill: parent
        activeFocusOnTab: true
        spacing: 8

        QC.Label {
            text: "Canais"
            color: "#E0E0EB"
            font.pixelSize: 16
            font.bold: true
        }

        QC.ButtonGroup{
            id: channelGroup
        }

        //RowLayout{

            // Layout.fillWidth: true
            // Layout.fillHeight: true
            // spacing: 0


        // QC.ScrollView{
        //     Layout.fillHeight: true
        //     Layout.fillWidth: true
        //     clip: true

        //     QC.ScrollBar.vertical: QC.ScrollBar{
        //         active: true
        //         policy: QC.ScrollBar.AsNeeded
        //         clip: true
        //     }


            ListView {
                id: channelView
                boundsBehavior: Flickable.OvershootBounds
                boundsMovement: Flickable.StopAtBounds
                //anchors.bottomMargin: 4
                //cacheBuffer: 880
                //synchronousDrag: true
                //boundsMovement: Flickable.FollowBoundsBehavior
                // boundsBehavior: Flickable.OvershootBounds
                Layout.fillWidth: true
                Layout.fillHeight: true
                width: parent.width
                //implicitHeight: contentHeight
                reuseItems: true
                model:channelListModel

                onMovementEnded: interactive = true
                onFlickEnded: interactive = true

                QC.ScrollBar.vertical: QC.ScrollBar{
                    interactive: false
                    clip: true
                    //policy: ScrollBar.AlwaysOn
                    policy:  ScrollBar.AsNeeded
                    // opacity: active ? 1.0 : 0

                    // Behavior on opacity {
                    //     NumberAnimation{
                    //         duration: 900
                    //     }
                    // }

                    snapMode: QC.ScrollBar.SnapOnRelease
                    hoverEnabled: true
                }



                spacing: 4
                //bottomPadding: 4
                delegate: QC.ItemDelegate {
                    width: channelView.width
                    height: 44
                //color: hovered ? "#393c43" : "transparent"
                    checkable: true
                    checked: index === 0
                    leftPadding: 16
                    rightPadding: 16
                    QC.ButtonGroup.group: channelGroup
                    text: model.name

                    onClicked:{
                        channelView.currentIndex = index
                        //função que muda de sala
                    }




                    // MouseArea{
                    //     anchors.fill: parent
                    //     onPressed: {
                    //         if(channelView.atYEnd){
                    //             channelView.interactive = false
                    //         }
                    //     }

                    //     onReleased: {
                    //         if(!channelView.interactive){
                    //             channelView.interactive = true
                    //         }
                    //     }

                    //     onClicked:{
                    //          channelView.currentIndex = index
                    //              //função que muda de sala
                    //         }
                    // }



                    background: Rectangle{
                        color: parent.checked ? "#4f545c" : "transparent"
                                            //"#393c43" : "transparent"

                        Rectangle{
                        anchors.fill: parent
                        color: "#40444b"
                        opacity: parent.hovered && !parent.checked ? 0.5 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                        }

                    }

                    contentItem: RowLayout {
                        spacing: 8
                            // anchors.left: parent.left
                            // anchors.right: parent.right
                            // anchors.verticalCenter: parent.verticalCenter
                            // anchors.leftMargin: 16
                            // anchors.rightMargin: 16
                                // text: parent.text
                                // color: white
                                // font: parent.font
                                // anchors.centerIn: parent

                        //Divisão do "Icone"
                        Text{
                            text: "#"
                            color: parent.parent.checkable ? "#ffffff" : "#b9bbbe"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        //Divisão do nome
                        Text{
                            Layout.fillHeight: true
                            text: model.channelName
                            color: parent.parent.checkable ? "#ffffff" : "#b9bbbe"
                            font.pixelSize: 16
                            font.bold: true
                            elide: Text.ElideRight
                        }


                        Item {
                            Layout.fillWidth: true // << ISSO EMPURRA O SELO PARA A DIREITA
                        }

                        //Notificação de Mensagem não lida

                        Rectangle{
                            id: unreadIcon
                            width: 20
                            height: 20
                            radius: 10
                            color: "#f04747"
                            visible: model.unreadCount > 0

                            Text{
                                text: model.unreadCount
                                anchors.centerIn: parent
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }
            }

            // ScrollBar{
            //     id:scroll
            //     clip: true
            //     Layout.fillHeight: true // Ocupa a altura do RowLayout
            //     //flickable: channelView  // Conecta à ListView
            //     //Flickable:channelView
            //     policy: ScrollBar.AsNeeded
            //     interactive: false
            // }


    }
}
