import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 600
    height: 400
    color: "#181825" // Mantle
    radius: 12
    border.color: "#313244" // Surface0
    border.width: 1
    clip: true
    
    property bool isOpen: false
    
    // Animação de entrada/saída
    visible: opacity > 0
    opacity: isOpen ? 1.0 : 0.0
    scale: isOpen ? 1.0 : 0.9
    
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

    signal close()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#11111b" // Crust
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 8
                
                Label {
                    text: "System Logs"
                    color: "#cdd6f4"
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "✕"
                    flat: true
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.hovered ? "#f38ba8" : "transparent"
                        radius: 4
                    }
                    contentItem: Label {
                        text: parent.text
                        color: parent.hovered ? "#11111b" : "#bac2de"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.close()
                }
            }
        }

        // Tabs (Visual only for now)
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: "#1e1e2e"
            
            Row {
                anchors.fill: parent
                spacing: 1
                
                Repeater {
                    model: ["Client"]//, "Server", "Network", "Debug"]
                    delegate: Rectangle {
                        //width: 100
                        //height: parent.height
                        width: parent.width
                        height: parent.height

                        color: index === 0 ? "#313244" : "transparent"
                        
                        Label {
                            anchors.centerIn: parent
                            text: modelData
                            color: index === 0 ? "#cdd6f4" : "#6c7086"
                            font.bold: index === 0
                        }
                    }
                }
            }
        }

        // Log Content
        ListView {
            id: logList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ListModel { id: logModel }
            boundsBehavior: Flickable.StopAtBounds
            
            Connections {
                target: backend
                function onLogReceived(timestamp, category, message) {
                    logModel.append({
                        "timestamp": timestamp,
                        "category": category,
                        "message": message
                    })
                    logList.positionViewAtEnd()
                }
            }
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 6
                background: Rectangle { color: "transparent" }
                contentItem: Rectangle {
                    radius: 3
                    color: "#45475a"
                }
            }

            delegate: Rectangle {
                width: logList.width
                height: 24
                color: index % 2 === 0 ? "transparent" : "#1e1e2e"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    spacing: 10
                    
                    Label {
                        text: "[" + model.timestamp + "]"
                        color: "#6c7086"
                        font.family: "Consolas"
                        font.pixelSize: 11
                    }
                    
                    Label {
                        text: "[" + model.category + "] " + model.message
                        color: model.category === "ERROR" ? "#f38ba8" : (model.category === "WARN" ? "#f9e2af" : "#a6e3a1")
                        font.family: "Consolas"
                        font.pixelSize: 11
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
