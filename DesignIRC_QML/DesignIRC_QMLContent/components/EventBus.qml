// EventBus.qml
pragma Singleton
import QtQuick

QtObject {
    id: root

    // ==================== SINAIS DE CANAL ====================

    // Quando um canal é selecionado
    signal channelSelected(string channelName)

    // Quando uma nova mensagem chega (de qualquer fonte)
    signal messageReceived(string channel, var messageData)

    // Quando o histórico de um canal é carregado
    signal channelHistoryLoaded(string channel, var messages)

    // Quando contador de não lidas muda
    signal unreadCountChanged(string channel, int count)


    // ==================== SINAIS DE USUÁRIO ====================

    // Quando status de um usuário muda
    signal userStatusChanged(string userName, string status)

    // Quando um usuário entra/sai de um canal
    signal userJoinedChannel(string userName, string channel)
    signal userLeftChannel(string userName, string channel)

    // Quando lista de usuários online é atualizada
    signal onlineUsersUpdated(var userList)


    // ==================== SINAIS DE NOTIFICAÇÃO ====================

    // Notificação genérica
    signal notificationTriggered(string title, string message, string type)

    // Quando você é mencionado
    signal userMentioned(string channel, string userName, string message)


    // ==================== SINAIS DE CONEXÃO ====================

    // Estado da conexão com backend
    signal connectionStatusChanged(bool connected)
    signal connectionError(string errorMessage)


    // ==================== SINAIS DE UI ====================

    // Para controlar loading states
    signal loadingStateChanged(string component, bool isLoading)

    // Para mostrar/esconder elementos
    signal showUserProfile(string userName)
    signal showChannelSettings(string channelName)


    // ==================== MÉTODOS UTILITÁRIOS ====================

    // Helper para emitir mensagem recebida com dados formatados
    function emitMessageReceived(channel, sender, message, messageType, timestamp) {
        var now = timestamp || new Date()
        var messageData = {
            sender: sender,
            message: message,
            messageType: messageType || "other",
            timestamp: now.toISOString(),
            displayDate: now.toLocaleDateString(undefined, {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            }),
            displayTime: now.toLocaleTimeString(undefined, {
                hour: '2-digit',
                minute: '2-digit'
            })
        }
        messageReceived(channel, messageData)
    }

    // Helper para emitir notificação
    function notify(title, message, type) {
        type = type || "info" // info, success, warning, error
        notificationTriggered(title, message, type)
    }

    // Log de debug (útil para desenvolvimento)
    property bool debugMode: true

    function log(message, data) {
        if (debugMode) {
            console.log("[EventBus]", message, data ? JSON.stringify(data) : "")
        }
    }
}
