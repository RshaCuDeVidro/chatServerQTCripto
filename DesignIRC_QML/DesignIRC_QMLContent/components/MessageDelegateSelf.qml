
import QtQuick 6.8
import QtQuick.Layouts 6.8

Item {
    width: chatListView.width
    height: messageContainer.height + dateText.height + 4 + 14


    Text {
        id: dateText
        text: model.displayDate
        color: "#8b8da3"
        font.pixelSize: 10


        anchors.right: parent.right
        anchors.margins: 8
        y: 0
    }

    Rectangle {
        id: messageContainer


        readonly property real maxWidth: chatListView.width * 0.70
        width: Math.min(columnChatArea.implicitWidth + 16, maxWidth)
        height: columnChatArea.implicitHeight + 16

        radius: 6
        color: "#8A3CD9"


        anchors.right: parent.right
        anchors.margins: 8
        anchors.top: dateText.bottom
        anchors.topMargin: 4

        ColumnLayout {
            id: columnChatArea
            anchors.centerIn: parent
            spacing: 4


            RowLayout {
                Layout.alignment: Qt.AlignRight


                Item {
                    Layout.fillWidth: true
                }


                Text {
                    text: model.displayTime
                    color: "#8b8da3"
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignBottom
                }


                Text {
                    text: model.sender
                    color: "white"
                    font.bold: true
                    Layout.leftMargin: 4
                }
            }

            Text {
                id: messageText
                text: model.message
                color: "white"
                wrapMode: Text.Wrap


                Layout.maximumWidth: messageContainer.maxWidth - 16
                Layout.alignment: Qt.AlignRight
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
