# Proyecto Pascal - Introducción a la Algoritmica y Programación

Este proyecto fue desarrollado como parte de la materia **Introducción a la Algoritmica y Programación** en la **Universidad Nacional de Río Cuarto (UNRC)**. 

## Descripción

El proyecto consiste en una aplicación escrita en Pascal que resuelve problemas específicos relacionados con algoritmos y estructuras de datos, utilizando los conocimientos adquiridos en la materia.

## Tecnologías utilizadas

- **Lenguaje de programación**: Pascal
- **Entorno de ejecución**: Docker
- **Compilador**: Free Pascal Compiler (FPC)

## Instrucciones para ejecutar el proyecto

1. **Construir la imagen de Docker:**

   ```bash
   docker build -t mi_proyecto_pascal .
    ```

2. **Ejecutar el contenedor:**

   ```bash
   docker run --rm -it -v $(pwd)/datosEleccion.dat:/app/datosEleccion.dat mi_proyecto_pascal
    ```