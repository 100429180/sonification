from pythonosc import dispatcher
from pythonosc import osc_server
from pythonosc import udp_client
import threading
import time

client = udp_client.SimpleUDPClient('127.0.0.1', 57120) #Establece la emisión de mensaje a la ip y puerto en la que escucha supercollider

def message_handler(address, *args):
    print("Received message from {}: {}".format(address, args)) #Muestra el mensaje recibido por la página web
    client.send_message(address,args) #Envía el mensaje recibido a supercollider a través del cliente definido anteriormente


if __name__ == "__main__":
    dispatcher = dispatcher.Dispatcher()
    dispatcher.map("/message", message_handler) #Muestra por pantalla y envía a supercollider cada uno de los mensajes con la address estípulada

    server = osc_server.ThreadingOSCUDPServer(("127.0.0.1", 7500), dispatcher)
    print("Server started at {}:{}".format(server.server_address[0], server.server_address[1]))

    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.start()

    try:
        while True:
            time.sleep(30)
    
    except KeyboardInterrupt:
        print("\nClosing OSCServer.")
        server.shutdown()
        print("Waiting for Server-thread to finish")
        server_thread.join()

