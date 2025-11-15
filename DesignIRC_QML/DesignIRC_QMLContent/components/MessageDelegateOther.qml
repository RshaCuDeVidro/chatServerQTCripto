
// import QtQuick 6.8
// import QtQuick.Layouts 6.8
import QtQuick 6.8

// O arquivo base faz todo o trabalho. Usamos o padrão (isSelf: false)
MessageDelegateBase {
    // isSelf: false (é o padrão)
}
// Item {
//     width: chatListView.width
//     height: messageContainer.height + dateText.height + 4 + 8

//     Text {
//         id: dateText
//         text: model.displayDate
//         color: "#97C2FF"//"#8b8da3"
//         font.pixelSize: 10


//         anchors.left: parent.left
//         anchors.margins: 8
//         y: 0
//     }


//     Rectangle {
//         id: messageContainer


//         readonly property real maxWidth: chatListView.width * 0.70
//         width: Math.min(columnChatArea.implicitWidth + 16, maxWidth)
//         height: columnChatArea.implicitHeight + 16

//         radius: 6
//         color: "#533872"


//         anchors.left: parent.left
//         anchors.margins: 8
//         anchors.top: dateText.bottom
//         anchors.topMargin: 4

//         ColumnLayout {
//             id: columnChatArea
//             anchors.centerIn: parent
//             spacing: 4


//             RowLayout {
//                 Layout.alignment: Qt.AlignLeft

//                 Layout.maximumWidth: messageContainer.maxWidth - 16

//                 Text {
//                     text: model.sender
//                     color: "#00C8FF"
//                     font.bold: true
//                 }


//                 Text {
//                     text: model.displayTime
//                     color: "white"//"#8b8da3"
//                     font.pixelSize: 10
//                     Layout.alignment: Qt.AlignBottom
//                     Layout.leftMargin: 4
//                 }

//                 Item {
//                     Layout.fillWidth: true
//                 }
//             }


//             Text {
//                 id: messageText
//                 text: model.message
//                 color: "white"
//                 wrapMode: Text.Wrap

//                 Layout.maximumWidth: messageContainer.maxWidth - 16
//                 Layout.alignment: Qt.AlignLeft
//                 horizontalAlignment: Text.AlignLeft
//             }
//         }
//     }
// }
