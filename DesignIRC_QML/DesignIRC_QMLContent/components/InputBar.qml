import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Rectangle {
    id: inputBar
    //height: 60
    implicitHeight: rowLayout.implicitHeight + 16
    width: parent ? parent.width : 400
    color: "#2f3136"
    //color: "#606178"
    radius: 10




    signal sendMessage(string msg)

    Rectangle {
        //anchors.fill: parent
        anchors.margins: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: rowLayout.height

        color: "transparent"


        RowLayout {
            id: rowLayout
            //anchors.fill: parent
            width:  parent.width
            spacing: 6


            TextArea {
                id: messageField
                color:  "white"
                Layout.fillWidth: true

                Layout.preferredHeight: messageField.implicitHeight//Math.min(implicitHeight, 120)
                Layout.maximumHeight: 120
                placeholderText: "Digite sua mensagem..."
                wrapMode: TextEdit.WordWrap
                selectionColor: "#a8c43afc"
                focus: true
                activeFocusOnPress: true
                //placeholderTextColor: "#7561f2"
                placeholderTextColor: "#ffffff"

                background: Rectangle {
                    id: messageFieldBackground
                    color: "#2C2C3F"
                    //color: "#3B3D4A"
                    //radius: 4
                    radius: 8
                    border.color: "#C800FF"
                    //border.width: 1.5

                    RectangularShadow {
                        id:messageNeon
                        anchors.fill: parent
                        z: -1

                        cached: true

                        //color: "#c800ff"
                        color: "#C800FF"
                        radius: 8
                        blur: 14
                        spread: 4

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

                }

                Keys.onPressed: (event) =>{
                    if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                        //Shift pressionado
                        if(!(event.modifiers & Qt.ShiftModifier)){
                            event.accepted = true
                            if(messageField.text.trim().length > 0){
                                sendMessage(messageField.text.trim())
                                messageField.text = ""
                            }
                        } else{
                            //evento passa e nova linha é criada
                            event.accepted = false
                        }

                    }

                }


             //    Keys.onEnterPressed:{
             //        if(messageField.text.length > 0){
             //            sendMessage(messageField.text)
             //            messageField.text = ""
             //        }
             //    }

             //    Keys.onReturnPressed:{
             //        if(messageField.text.length > 0){
             //            sendMessage(messageField.text)
             //            messageField.text = ""
             //        }
             //    }
            }

//#5a8fd9
//#2f02c4
            Button {
                id: sendButton
                visible: true
                text: "➤"
                font.pixelSize: 18

                Layout.alignment: Qt.AlignBottom
                Layout.preferredWidth: 40// parent.height
                Layout.preferredHeight: 40
                background:Rectangle {
                    id: btReact
                    //color: "#8A2BE2"
                    //radius: 4
                    color: "#2C2C3F"
                    radius: 8
                    border.color: "#C800FF"
                    border.width: 1.5


                    RectangularShadow {
                        anchors.fill: parent
                        cached: true
                        z: -1


                        color: "#C800FF"
                        // radius: 10
                        // blur: 7
                        // spread: 3
                        offset.x: 0
                        offset.y: 0


                        blur: 10
                        radius: 8
                        spread: 3


                        PropertyAnimation on blur{

                            easing.bezierCurve: [0.42,0,0.58,1]



                            running: true
                            loops: -1

                            from: 14
                            to: 10
                            duration: 1500
                        }

                        PropertyAnimation on spread {
                            easing.bezierCurve: [0.42,0,0.58,1]
                            running: true
                            loops: -1

                            from: 6
                            to: 3
                            duration: 1500


                        }  //fim animação

                    }


                }

                contentItem: Text{
                    text: sendButton.text
                    font: sendButton.font
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (messageField.text.trim().length > 0) {
                        sendMessage(messageField.text.trim())
                        messageField.text = ""
                    }
                }

                Keys.onPressed: (event) =>{
                    if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return ){
                        if(messageField.text.trim().length > 0){
                            sendMessage(messageField.text.trim())
                            messageField.text = ""
                            event.accepted = true
                        }
                    }
                }
            }
        }
    }
}
