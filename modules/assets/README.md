# Assets

Esta carpeta contiene recursos estáticos utilizados por los módulos del sistema.

## Estructura

```
assets/
├── images/
│   └── dreamcoder/          # Imágenes del tema Dreamcoder
│       ├── Dreamcoder01.jpg
│       ├── Dreamcoder02.jpg
│       ├── Dreamcoder03.jpg
│       ├── Dreamcoder04.jpg
│       ├── Dreamcoder05.jpg
│       ├── Dreamcoder06.jpg
│       ├── Dreamcoder07.jpg
│       ├── Dreamcoder08.jpg
│       └── Dreamcoder09.jpg
└── README.md
```

## Propósito

- **Separación de responsabilidades**: Los módulos de configuración no deben contener recursos estáticos
- **Mantenimiento**: Facilita la gestión y actualización de recursos
- **Organización**: Estructura clara y lógica para todos los assets del sistema

## Uso

Los módulos pueden referenciar estos assets desde sus scripts de instalación o configuración.
