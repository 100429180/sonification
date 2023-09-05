from pythonosc import dispatcher
from pythonosc import osc_server
import threading
import time

message_count = 0
max_values = []
min_values = []

def message_handler(address, *args):
    global message_count, max_values, min_values

    # Incrementa el contador de mensajes
    message_count += 1

    # Verifica si se han recibido los primeros mil mensajes
    if message_count <= 2000: 
        if message_count>500:
            print("calibrando...")
        # Actualiza los arrays de máximos y mínimos
            if not max_values:
                max_values = list(args)
                min_values = list(args)
            else:
                for i in range(len(args)):
                    if args[i] > max_values[i]:
                        max_values[i] = args[i]
                    if args[i] < min_values[i]:
                        min_values[i] = args[i]
        else:
            print("preparando la medición")
    else:
        # Finaliza el script después de recibir los primeros mil mensajes
        print("Received the first 1000 messages. Exiting the script.")
        raise SystemExit
    print(message_count);

if __name__ == "__main__":
    dispatcher = dispatcher.Dispatcher()
    dispatcher.map("/message", message_handler)  # Muestra por pantalla y procesa cada uno de los mensajes con la dirección especificada
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

    # Imprime los resultados
    print("Max values:")
    for value in max_values:
        print(value)
    print("Min values:")
    for value in min_values:
        print(value)
