import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Rectangle {
    id: inputBar
    height: 60
    width: parent ? parent.width : 400
    color: "#2f3136"
    //color: "#606178"
    radius: 10

    // layer.enabled: true
    // layer.effect: DropShadow{
    //     color: "#8b000000"
    //     //color: "#0E0E12"
    //     radius: 20
    //     spread: 0.2
    //     transparentBorder: true
    //     samples: 32
    //     cached: true

    // }


    signal sendMessage(string msg)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        color: "transparent"

        RowLayout {
            id: rowLayout
            anchors.fill: parent
            spacing: 6

            RectangularShadow {
                id:messageNeon
                anchors.fill: messageField
                Layout.maximumHeight: 0
                Layout.maximumWidth: 0
                cached: true

                //color: "#c800ff"
                color: "#C800FF"
                radius: 8
                blur: 14
                spread: 4

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

            RectangularShadow {
                anchors.fill: sendButton
                Layout.maximumHeight: 0
                Layout.maximumWidth: 0
                cached: true


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
                    //easing.bezierCurve: [0.0388,0.452,0.032,1.15,0.0631,1.22,0.112,1.15,0.147,0.892,0.193,0.859,0.236,0.905,0.301,1.08,0.364,1.04,0.45,0.94,0.636,0.997,0.682,1.02,0.746,1.04,0.775,0.99,1,1]
                    easing.bezierCurve: [0.42,0,0.58,1]
                    //easing.bezierCurve: [0.2,0.2,0.8,0.8,1,1]
                    //easing.bezierCurve: [0.25,0.46,0.45,0.94,1,1]


                    running: true
                    loops: -1

                    from: 14
                    to: 10
                    duration: 1500
                }

                PropertyAnimation on spread {
                    easing.bezierCurve: [0.42,0,0.58,1]
                    //easing.bezierCurve: [0.0553,0.0385,0.0796,-0.0381,0.109,-0.0381,0.138,-0.0381,0.185,0.0276,0.222,0.00353,0.259,-0.0205,0.332,-0.25,0.385,-0.252,0.462,-0.14,0.543,1.18,0.617,1.24,0.676,1.24,0.738,1,0.778,0.977,0.817,0.953,0.855,1.02,0.889,1.03,0.924,1.03,0.951,0.964,1,1]
                    //easing.bezierCurve: [0.257,-0.00742,0.35,0.0559,0.444,0.0517,0.533,0.0539,0.605,-0.0162,0.657,-0.0271,0.741,-0.0118,0.733,0.124,0.776,0.168,0.82,0.131,0.842,-0.0446,0.88,-0.084,0.912,-0.0402,0.955,0.432,1,1]
                    running: true
                    loops: -1

                    from: 6
                    to: 3
                    duration: 1500


                }  //fim animação

            }

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
                    id: messageFieldBackground
                    color: "#2C2C3F"
                    //color: "#3B3D4A"
                    //radius: 4
                    radius: 8
                    border.color: "#C800FF"
                    border.width: 1.5
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
             }

//#5a8fd9
//#2f02c4
            Button {
                id: sendButton
                visible: true
                text: "Enviar"
                background:Rectangle {
                    id: btReact
                    //color: "#8A2BE2"
                    //radius: 4
                    color: "#2C2C3F"
                    radius: 8
                    border.color: "#C800FF"
                    border.width: 1.5
                }

                contentItem: Text{
                    text: sendButton.text
                    font: sendButton.font
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

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
            }
        }
    }
}
