import QtQuick
import QtQuick.Layouts
//TESTE MALUCO
Item {
    width: chatListView.width
    height: textBlock.implicitHeight + 16

    Rectangle {
        id: textBlock
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        border.color: "#666"
        border.width: 1
        radius: 6
        //padding: 6
        width: Math.min(messageText.implicitWidth + 24, chatListView.width * 0.8)
        height: messageText.implicitHeight + 8

        Text {
            id: messageText
            text: model.message
            color: "#AAAAAA"
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            anchors.centerIn: parent
        }
    }
}
