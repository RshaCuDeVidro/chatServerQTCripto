import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
        color: "#36393f"
        Rectangle {
        id: rectangle
        anchors.fill: parent
        anchors.margins: 10
        color: "transparent"


        ListModel {
                    id: chatModel
                    ListElement{message: "c "; is_self: true}
                    ListElement{message: "c "; is_self: true}
                    ListElement{message: "c "; is_self: true}
                    ListElement{message: "c "; is_self: true}
                    ListElement{message: "c "; is_self: true}
                    ListElement{message: "c "; is_self: false}
                    ListElement{message: "c "; is_self: false}
                    ListElement{message: "c "; is_self: false}
                    ListElement{message: "c "; is_self: true}
                    ListElement{message: "c "; is_self: false}

                    }


        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: 6
            anchors.margins: 10

            anchors.bottom: inputBar.top

            Label {
                color: "white"
                text: "Canal: #"
                font.bold: true
                font.pixelSize: 18

            }
                ListView {
                    id: chatListView
                    activeFocusOnTab: true
                    Layout.bottomMargin: 49
                    boundsBehavior: Flickable.StopAtBounds
                    boundsMovement: Flickable.FollowBoundsBehavior
                    synchronousDrag: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: 4
                    clip: true
                    reuseItems: true

                    ScrollBar.vertical: ScrollBar{

                                        policy: ScrollBar.AsNeeded

                    }

                    model: chatModel

                    delegate: Item {
                                        height: messageContainer.height
                                        width: chatListView.width


                                        Rectangle{
                                                            id:messageContainer
                                                            width: chatListView.width * 0.7
                                                            height: messageText.implicitHeight + 20
                                                            color: "#7E32BC"
                                                            radius: 5

                                                            // Lógica de alinhamento testada
                                                            anchors.right: model.is_self ? parent.right : undefined
                                        anchors.left: model.is_self ? undefined : parent.left
                                        //color: model.is_self ? "#dcf8c6" : "#ffffff"
                                        //border.color: "#e0e0e0"

                                        Text {
                                                            id: messageText

                                                            text: model.message
                                                            anchors.fill: parent
                                                            anchors.margins: 10
                                                            wrapMode: Text.WordWrap

                                        }






                        }

                    }


                    // delegate: Text {
                    //     text: model.message
                    //     color: "white"
                    //     wrapMode: Text.WordWrap
                    //     font.pixelSize: 16
                    //     width: chatListView.width
                    //     textFormat: Text.PlainText

                    //      // MouseArea {
                    //      //                          anchors.fill: parent
                    //      //                          acceptedButtons: Qt.LeftButton
                    //      //                          onClicked: parent.forceActiveFocus()
                    //      //                          onDoubleClicked: parent.selectAll()
                    //      // }

                    //  }


                    // MouseArea {
                    //                          anchors.fill: parent
                    //                          cursorShape: Qt.PointingHandCursor
                    //                          hoverEnabled: true
                    //                          scrollGestureEnabled: false
                    //                          enabled: true
                    //                          acceptedButtons: Qt.AllButtons
                    //                          onWheel: (wheel) => {
                    //                                                            chatListView.flick(0, -wheel.angleDelta.y)
                    //                     }
                    //                 }


                }

        }


        InputBar {
            id: inputBar
            anchors.bottom: parent.bottom
            //anchors.topMargin: -45
            anchors.bottomMargin: 0

            //anchors.top: column.bottom
            Layout.fillWidth: true
            onSendMessage: (msg) => {
                chatModel.append({message: "<Teste> " +  msg, is_self: true})
                chatListView.positionViewAtEnd() }
        }




    }


}
