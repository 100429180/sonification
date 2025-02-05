Este proyecto manda como mensaje a Supercollider un array (metricsResult) que contiene todas las métricas de todas las partes del cuerpo, mandando un mensaje por cada pose detectada.

1) En la carpeta principal (Web-python-Supercollider) ejecutar en la terminal: "node ."
2) Abrir la página web
3) Abrir el archivo de Supercollider y ejecutarlo
4) En la carpeta principal, en la terminal, ejecutar el programa python que hace de puente entre la página web y supercollider "python web-supercollider.py"

Para poder realizar esta conexión, he tenido que desactivar el Firewall para poder enviar los mensajes UDP. Para ello:

1) Panel de control
2) Sistema y seguridad
3) Firewall de Windows
4) Configuración avanzada
5) Reglas de entrada
6) Nueva regla
7) Tipo de regla: puerto
8) UDP, Todos los puertos locales
9) Permitir la conexión
