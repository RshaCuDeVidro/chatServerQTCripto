import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//import QtQuick.Studio.DesignEffects
import QtQuick.Effects

Rectangle {
    id: inputBar
    height: 60
    width: parent ? parent.width : 400
    color: "#2f3136"
    radius: 10

    signal sendMessage(string msg)
    //não uso

    // DesignEffect {
    //     visible: true
    //     effects: [
    //         DesignDropShadow {
    //             color: "#C800FF"
    //             offsetX: 0
    //             offsetY: 2
    //             //offsetX: 4
    //             showBehind: true
    //             blur: 60

    //         },
    //         DesignInnerShadow {
    //             color: "#C800FF"
    //             offsetY: 1
    //             //offsetX: 4
    //             showBehind: true
    //             blur: 60
    //         }
    //     ]
    // }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        color: "transparent"



        RowLayout {
            anchors.fill: parent
            spacing: 6

            TextField {
                id: messageField
                color:  "white"
                Layout.fillWidth: true
                placeholderText: "Digite sua mensagem..."
                wrapMode: Text.NoWrap
                focus: true
                overwriteMode: true
                activeFocusOnPress: true
                //placeholderTextColor: "#7561f2"
                placeholderTextColor: "#ffffff"
                background: Rectangle {
                    //color: "#40444b"
                    color: "#2C2C3F"
                    //radius: 4
                    radius: 8
                    border.color: "#c800ff"
                }

                Keys.onEnterPressed:{
                    if(messageField.text.length > 0){
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }

                Keys.onReturnPressed:{
                    if(messageField.text.length > 0){
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }

            //     DesignEffect {
            //         visible: true
            //         effects: [
            //             DesignDropShadow {
            //                 color: "#C800FF"
            //                 offsetX: 0
            //                 offsetY: 2
            //                 //offsetX: 4
            //                 showBehind: false
            //                 blur: 20

            //             },
            //             DesignInnerShadow {
            //                 color: "#C800FF"
            //                 offsetY: 1
            //                 //offsetX: 4
            //                 showBehind: false
            //                 blur: 20
            //             }
            //         ]
            //     }
             }
//#5a8fd9
//#2f02c4
            Button {
                id: sendButton
                visible: true
                text: "Enviar"
                icon.color: "#ffffff"
                highlighted: true
                background:Rectangle {
                    //color: "#8A2BE2"
                     //radius: 4
                    color: "#2C2C3F"
                     radius: 8
                     border.color: "#c800ff"
                }
                Layout.bottomMargin: 3
                icon.width: 25
                onClicked: {
                    if (messageField.text.length > 0) {
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }



                Keys.onEnterPressed:{
                    if(messageField.text.length > 0){
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }

                Keys.onReturnPressed:{
                    if(messageField.text.length > 0){
                        sendMessage(messageField.text)
                        messageField.text = ""
                    }
                }

                // DesignEffect {
                //     visible: true
                //     effects: [
                //         DesignDropShadow {
                //             color: "#C800FF"
                //             offsetX: 0
                //             offsetY: 2
                //             //offsetX: 4
                //             showBehind: false
                //             blur: 20

                //         },
                //         DesignInnerShadow {
                //             color: "#C800FF"
                //             offsetY: 1
                //             //offsetX: 4
                //             showBehind: false
                //             blur: 20
                //         }
                //     ]
                // }
            }
        }
    }
}

