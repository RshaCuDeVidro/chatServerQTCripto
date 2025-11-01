// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts
// // Importação "DesignEffects" removida
// import QtQuick.Effects // Importação necessária para MultiEffect e RectangularShadow

// Rectangle {
//     id: channelList
//     color: "#2f3136"
//     //radius: 10
//     //Layout.fillHeight: true
//     //Layout.fillWidth: true

//     signal channelSelected(string name)

//     // =================================================================
//     // INÍCIO: EFEITO NEON/GLOW (Substituição do DesignEffect)
//     //
//     // Esta é a abordagem moderna (Qt 6) usando 'layer.effect'.
//     // É mais limpo e mais performático.
//     // =================================================================
//     layer.enabled: true // Habilita o cache de renderização para efeitos
//     layer.effect: RectangularShadow {
//         // Ancora o efeito à camada do 'channelList'
//         anchors.fill: channelList

//         // 1. Configuração do Glow Neon
//         offset.x: 0 // Centraliza a sombra
//         offset.y: 0
//         blur: 16    // Desfoque base para o brilho
//         spread: 0
//         color: "#C800FF" // Cor neon roxa do seu design [cite: 2]
//         radius: channelList.radius // Usa o raio do pai (se definido)

//         // 2. Animação de Pulsação (como sugerido)
//         SequentialAnimation on blur {
//             running: true
//             loops: Animation.Infinite // Repete para sempre

//             // Pulsação suave (2 segundos)
//             NumberAnimation { to: 18; duration: 2000; easing.type: Easing.InOutSine }
//             NumberAnimation { to: 16; duration: 2000; easing.type: Easing.InOutSine }

//             // Falha/Flicker (a cada 4 segundos)
//             PauseAnimation { duration: 4000 }
//             NumberAnimation { to: 14; duration: 70 }
//             NumberAnimation { to: 16; duration: 70 }
//             NumberAnimation { to: 14; duration: 70 }
//             NumberAnimation { to: 16; duration: 70 }
//         }
//     }
//     // =================================================================
//     // FIM: EFEITO NEON/GLOW
//     // =================================================================


//     // ===========================
//     // Modelo de canais (embutido)
//     // ===========================
//     ListModel {
//         id: channelListModel
//         ListElement { channelName: "geral"; unreadCount: 3 }
//         ListElement { channelName: "dev"; unreadCount: 0 }
//         ListElement { channelName: "design"; unreadCount: 10 }
//         ListElement { channelName: "aleatorio"; unreadCount: 0 }
//         ListElement { channelName: "testes"; unreadCount: 0 }
//         ListElement { channelName: "offtopic"; unreadCount: 0 }
//         ListElement { channelName: "uiux"; unreadCount: 1 }
//         ListElement { channelName: "backend"; unreadCount: 0 }
//         ListElement { channelName: "geral"; unreadCount: 3 }
//         ListElement { channelName: "dev"; unreadCount: 0 }
//         ListElement { channelName: "design"; unreadCount: 10 }
//         ListElement { channelName: "aleatorio"; unreadCount: 0 }
//         ListElement { channelName: "testes"; unreadCount: 0 }
//         ListElement { channelName: "Sal de aula"; unreadCount: 0 }
//         ListElement { channelName: "design 2"; unreadCount: 1 }
//         ListElement { channelName: "aleatorio"; unreadCount: 0 }
//         ListElement { channelName: "testes"; unreadCount: 0 }
//         ListElement { channelName: "dev"; unreadCount: 0 }
//         ListElement { channelName: "design"; unreadCount: 1 }
//         ListElement { channelName: "aleatorio"; unreadCount: 5 }
//         ListElement { channelName: "testes"; unreadCount: 10 }
//         ListElement { channelName: "design"; unreadCount: 1 }
//         ListElement { channelName: "design"; unreadCount: 1 }
//     }

//     ColumnLayout {
//         anchors.fill: parent
//         anchors.margins: 10
//         spacing: 8

//         // Bloco DesignEffect removido daqui [cite: 28, 29, 30]

//         Label {
//             text: "Canais"
//             color: "#E0E0EB"
//             font.pixelSize: 18
//             font.bold: true
//             horizontalAlignment: Text.AlignHCenter
//             Layout.fillWidth: true
//         }

//         Rectangle {
//             id: container
//             color: "#2C2C3F"
//             radius: 8
//             border.color: "#C800FF"
//             border.width: 1 // Adicionado para a borda ser visível
//             Layout.fillWidth: true
//             Layout.fillHeight: true
//             clip: true

//             // =================================================================
//             // INÍCIO: EFEITO DE BRILHO INTERNO (INNER GLOW)
//             // =================================================================
//             MultiEffect {
//                 source: container
//                 anchors.fill: container

//                 // Simula o DesignInnerShadow
//                 innerGlowEnabled: true
//                 innerGlowColor: "#C800FF"  // Cor roxa
//                 innerGlowRadius: 10
//                 innerGlowSpread: 0.1
//                 innerGlowOpacity: 0.7
//             }
//             // =================================================================
//             // FIM: EFEITO DE BRILHO INTERNO
//             // =================================================================

//             ListView {
//                 id: channelView
//                 anchors.fill: parent
//                 clip: true
//                 spacing: 6
//                 boundsBehavior: Flickable.StopAtBounds
//                 model: channelListModel

//                 ScrollBar.vertical: ScrollBar {
//                     policy: ScrollBar.AsNeeded
//                     active: true
//                     visible: true
//                     width: 8
//                     background: Rectangle { color: "transparent" }
//                     contentItem: Rectangle {
//                         radius: 4
//                         color: "#C800FF"
//                         // Nota: Adicionar glow aqui (RectangularShadow)
//                         // pode não ser renderizado corretamente por causa do clipping
//                         // da ScrollBar. Manter a cor sólida é mais seguro.
//                     }
//                 }

//                 delegate: ItemDelegate {
//                     width: channelView.width
//                     height: 44
//                     checkable: true
//                     checked: ListView.isCurrentItem

//                     background: Rectangle {
//                         radius: 6
//                         color: checked ? "#4f545c" : "transparent"
//                         Rectangle {
//                             anchors.fill: parent
//                             color: "#40444b"
//                             opacity: hovered && !checked ? 0.5 : 0.0
//                             Behavior on opacity { NumberAnimation { duration: 100 } }
//                         }
//                     }

//                     contentItem: RowLayout {
//                         spacing: 10
//                         anchors.verticalCenter: parent.verticalCenter

//                         Label {
//                             text: "#" + model.channelName
//                             color: checked ? "white" : "#b9bbbe"
//                             font.pixelSize: 16
//                             font.bold: true
//                             elide: Text.ElideRight
//                             Layout.fillWidth: true
//                         }

//                         //  mensagens não lidas
//                         Rectangle {
//                             width: 22
//                             height: 22
//                             radius: 11
//                             color: "#f04747"
//                             visible: model.unreadCount > 0

//                             Label {
//                                 anchors.centerIn: parent
//                                 text: model.unreadCount
//                                 color: "white"
//                                 font.pixelSize: 12
//                                 font.bold: true
//                             }
//                         }
//                     }

//                     onClicked: {
//                         channelView.currentIndex = index
//                         channelList.channelSelected(model.channelName)
//                     }
//                 }
//             }
//         }
//     }
// }
