

# CRUD Dart - Sistema de Rutas Escolares

Un sistema simple de gestión de rutas escolares y contratos implementado en Dart.

## Requisitos Previos

- Dart SDK instalado (versión 2.19.0 o superior)
- Redis Server instalado y corriendo
- Git (opcional, para clonar el repositorio)
- Docker (opcional, para correr una instancia de redis local)

## Instalación

1. Clona el repositorio (o descarga el código):
```bash
git clone https://github.com/szm11/Crud-dart-actividad
cd Crud-dart-actividad
```

2. Asegúrate que Redis esté corriendo:

```
docker run --name redis-instance -p 6379:6379 -d redis:latest
```

3. Instala las dependencias:
```bash
dart pub get
```

## Ejecución

Para ejecutar el programa:
```bash
dart run
```

## Funcionalidades

El sistema permite:
- Crear y listar rutas escolares
- Crear, consultar, actualizar y listar contratos
- Asociar rutas con contratos
- Búsqueda de contratos

## Estructura del Menú

1. Crear contrato
2. Consultar contrato
3. Actualizar contrato
4. Listar contratos
5. Buscar contratos
6. Crear ruta
7. Listar rutas
8. Salir
