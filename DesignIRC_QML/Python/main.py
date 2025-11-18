# main_py_qasync.py

import sys
import asyncio
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

import qasync

from autogen.settings import setup_qt_environment
from backend_bridge import BackendBridge


async def main_async(app: QGuiApplication): # <--- Aceita o 'app'
    """Função principal assíncrona"""

    app.setApplicationName("IRC Chat")
    app.setOrganizationName("ChatApp")

    engine = QQmlApplicationEngine()

    backend = BackendBridge(server_uri="ws://localhost:8765")
    engine.rootContext().setContextProperty("backend", backend)
    print("Backend Bridge configurado (qasync)")

    setup_qt_environment(engine)

    if not engine.rootObjects():
        print("Erro: Não foi possível carregar main.qml")
        return 1

    print("Interface carregada")

    # Conecta ao servidor
    asyncio.create_task(backend.connect_to_server())

    # ==================== CORREÇÃO DO SHUTDOWN ====================

    # 1. Cria um evento de 'parada'
    shutdown_event = asyncio.Event()

    # 2. Conecta o sinal 'aboutToQuit' do Qt para 'setar' o evento
    def on_about_to_quit():
        print("Aplicação fechando...")
        shutdown_event.set()

    app.aboutToQuit.connect(on_about_to_quit)

    # 3. O loop agora espera pelo evento de 'parada'
    await shutdown_event.wait()

    # ==============================================================

    # Cleanup
    #await backend.cleanup()
    # Para o timer de debounce
    if hasattr(backend, '_channel_debounce_timer'):
        backend._channel_debounce_timer.stop()
    # Fecha WebSocket com try/except
    try:
        await asyncio.wait_for(backend.cleanup(), timeout=3.0)
    except asyncio.TimeoutError:
        print(" Timeout no cleanup")
    except RuntimeError as e:
        if "no running event loop" in str(e):
            print(" Loop de eventos já encerrado, cleanup ignorado.")
        else:
            print(f" Erro no cleanup: {e}")
    except Exception as e:
        print(f" Erro no cleanup: {e}")
    # ===========================

    print("Aplicação encerrada")
    return 0


def main():
    """Entry point"""
    try:
        app = QGuiApplication(sys.argv) # Criado apenas uma vez

        loop = qasync.QEventLoop(app)
        asyncio.set_event_loop(loop)

        with loop:
            exit_code = loop.run_until_complete(main_async(app)) # Passa o 'app'
            sys.exit(exit_code)

    except KeyboardInterrupt:
        print("\n Aplicação interrompida")
        sys.exit(0)

if __name__ == "__main__":
    main()
