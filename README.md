# flutter-cristophergomez

Este es un proyecto de ejemplo en Flutter que muestra cómo gestionar citas con funcionalidades de edición, eliminación y visualización en una lista. La aplicación permite interactuar con una API RESTful para realizar operaciones CRUD sobre las citas.

## Requisitos

Antes de ejecutar la aplicación, asegúrate de tener instalados los siguientes programas:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) o [Visual Studio Code](https://code.visualstudio.com/) con las extensiones de Flutter y Dart

## Instalación

1. **Clonar el repositorio**

   ```bash
   git clone https://github.com/cristopher-gomez-m/flutter-cristophergomez.git
   cd flutter-cristophergomez

2 **Instalar dependencias**
flutter pub get

3.**Configurar el emulador o dispositivo físico**

Para Android: Asegúrate de tener un emulador de Android configurado o un dispositivo físico conectado.

Para iOS (solo en macOS): Asegúrate de tener un simulador de iOS configurado o un dispositivo físico conectado.

4.**Ejecutar la aplicación**
flutter run


Estructura del Proyecto

lib/: Contiene el código fuente principal de la aplicación.

main.dart: Punto de entrada de la aplicación.

screens/: Contiene las pantallas de la aplicación.

services/: Contiene los servicios para interactuar con la API.

test/: Contiene las pruebas unitarias de la aplicación.

Funcionalidades

login

Visualizar citas: Muestra una lista de todas las citas almacenadas.

Editar cita: Permite modificar los detalles de una cita existente.

Eliminar cita: Permite eliminar una cita de la lista.

Agregar cita: Permite agregar una nueva cita a la lista.
