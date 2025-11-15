import QtQuick
import QtQuick.Layouts

Item {
    // A propriedade que controla tudo. O padrão é 'false' (Outro).
    property bool isSelf: false

    // Propriedades de acesso (para que 'chatListView' seja encontrado)
  /*  property alias chatListView: chatListView
    property var model: model*/ // Permite que o modelo seja passado

    // Referência à ListView (necessária para maxWidth)
    readonly property ListView chatListView: ListView.view

    width: chatListView.width
    height: messageContainer.height + dateText.height + 4 + 8

    // Data (Ex: 06/11/2025)
    Text {
        id: dateText
        text: model.displayDate
        color: "#97C2FF"
        font.pixelSize: 10

        // LÓGICA CONDICIONAL: Alinha à direita se 'isSelf' for verdadeiro
        anchors.right: isSelf ? parent.right : undefined
        anchors.left: isSelf ? undefined : parent.left

        anchors.margins: 8
        y: 0
    }

    // A Bolha de Mensagem
    Rectangle {
        id: messageContainer

        // Propriedade de largura máxima (compartilhada)
        readonly property real maxWidth: chatListView.width * 0.70
        width: Math.min(columnChatArea.implicitWidth + 16, maxWidth)
        height: columnChatArea.implicitHeight + 16
        radius: 6

        // LÓGICA CONDICIONAL: Muda a cor
        color: isSelf ? "#8A3CD9" : "#533872"

        // LÓGICA CONDICIONAL: Muda a âncora
        anchors.right: isSelf ? parent.right : undefined
        anchors.left: isSelf ? undefined : parent.left

        anchors.margins: 8
        anchors.top: dateText.bottom
        anchors.topMargin: 4

        // O conteúdo (coluna interna)
        ColumnLayout {
            id: columnChatArea
            anchors.centerIn: parent
            spacing: 4

            // O Cabeçalho (Nome + Hora)
            RowLayout {
                // LÓGICA CONDICIONAL: Muda o alinhamento
                Layout.alignment: isSelf ? Qt.AlignRight : Qt.AlignLeft

                // A correção de bug que aplicamos (compartilhada)
                Layout.maximumWidth: messageContainer.maxWidth - 16

                // LÓGICA CONDICIONAL: O espaçador vem primeiro se 'isSelf'
                Item { Layout.fillWidth: true; visible: isSelf }

                // O 'sender' para 'OutroUser' (vem primeiro)
                Text {
                    visible: !isSelf // Só aparece se NÃO for 'isSelf'
                    text: model.sender
                    color: "#00C8FF"
                    font.bold: true
                }

                // A Hora (compartilhada)
                Text {
                    text: model.displayTime
                    color: "white"
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignBottom
                    Layout.leftMargin: 4 // Margem para ambos os casos
                }

                // O 'sender' para 'Você' (vem por último)
                Text {
                    visible: isSelf // Só aparece se FOR 'isSelf'
                    text: model.sender
                    color: "white"
                    font.bold: true
                    Layout.leftMargin: 4
                }

                // LÓGICA CONDICIONAL: O espaçador vem por último se não for 'isSelf'
                Item { Layout.fillWidth: true; visible: !isSelf }
            }

            // O Texto da Mensagem (compartilhado)
            Text {
                id: messageText
                text: model.message
                color: "white"
                wrapMode: Text.Wrap

                // A correção de bug (compartilhada)
                Layout.maximumWidth: messageContainer.maxWidth - 16

                // LÓGICA CONDICIONAL: Muda o alinhamento
                Layout.alignment: isSelf ? Qt.AlignRight : Qt.AlignLeft
                horizontalAlignment: isSelf ? Text.AlignRight : Text.AlignLeft
            }
        }
    }
}
