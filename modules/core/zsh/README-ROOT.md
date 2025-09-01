# 🚀 Configuración ZSH Optimizada para Root - Arch Dream v5.0

Esta configuración proporciona una experiencia ZSH optimizada específicamente para el usuario root, con integración completa al proyecto Arch Dream y características de seguridad y productividad mejoradas.

## ✨ Características Principales

### 🔒 Seguridad Mejorada
- Aliases con confirmación para comandos peligrosos (`rm`, `chmod`, `chown`)
- Protección `--preserve-root` en comandos críticos
- Prompt distintivo para identificar sesión root
- Historial optimizado con verificación

### ⚡ Rendimiento Optimizado
- Configuración minimalista sin overhead innecesario
- Autocompletado inteligente optimizado
- PATH específico para administración del sistema
- Cache organizado en directorios XDG

### 🛠️ Herramientas Administrativas
- Aliases específicos para gestión del sistema
- Funciones para monitoreo y mantenimiento
- Integración con systemctl y journalctl
- Comandos de limpieza automatizados

### 🚀 Integración Arch Dream
- CLI completo disponible como `ad` 
- Funciones de navegación rápida (`cd-ad`, `ls-ad`)
- Variables de entorno del proyecto configuradas
- Información del sistema con datos de Arch Dream

## 📦 Instalación

### Instalación Automática
```bash
# Ejecutar como usuario normal
sudo /home/dreamcoder08/Documentos/PROYECTOS/Arch_Dream08/modules/core/zsh/install-root-config.sh
```

### Instalación Manual
```bash
# Como root
cp /home/dreamcoder08/Documentos/PROYECTOS/Arch_Dream08/modules/core/zsh/root/.zshrc /root/.zshrc
chsh -s /usr/bin/zsh root
```

## 🔄 Auto-Aplicación

La configuración se aplica automáticamente cuando:
- Se usa `sudo -i`
- Se ejecuta `su -`
- Se inicia sesión directa como root

Esto se logra mediante el hook integrado en la configuración principal de zsh.

## 🎯 Aliases Principales

### Navegación y Archivos
- `..`, `...`, `....` - Navegación rápida
- `ll`, `la` - Listados con iconos (si eza está disponible)
- `cp`, `mv`, `rm` - Operaciones con confirmación

### Sistema
- `pac`, `paci`, `pacu` - Gestión de paquetes Pacman
- `services` - Listar servicios systemd
- `ports` - Ver puertos abiertos
- `top` - Monitor de sistema (btop/htop si están disponibles)

### Utilidades
- `sysinfo` - Información completa del sistema
- `system-cleanup` - Limpieza automática
- `backup <archivo>` - Backup con timestamp
- `logs [servicio]` - Monitoreo de logs

## 🔧 Funciones Especializadas

### `service-status <servicio>`
Muestra el estado detallado de un servicio systemd.

### `system-cleanup`
Ejecuta rutinas de limpieza del sistema:
- Cache de pacman
- Logs antiguos (journalctl)
- Archivos temporales

### `sysinfo`
Muestra información completa del sistema:
- Usuario actual y hostname
- Uptime y versión del kernel
- Uso de memoria y disco

## 📁 Estructura de Directorios

```
modules/core/zsh/
├── root/
│   └── .zshrc                 # Configuración optimizada para root
├── install-root-config.sh     # Instalador automático
├── auto-apply-root.sh         # Auto-aplicador de configuración
└── README-ROOT.md             # Esta documentación
```

## ⚙️ Personalización

### Variables de Entorno
```bash
# Modificar en /root/.zshrc
export EDITOR='tu-editor-preferido'
export PAGER='tu-pager-preferido'
```

### Aliases Personalizados
```bash
# Añadir al final de /root/.zshrc
alias mi-alias='mi-comando'
```

### Funciones Personalizadas
```bash
# Ejemplo de función personalizada
mi-funcion() {
    echo "Mi función personalizada"
}
```

## 🔍 Troubleshooting

### La configuración no se aplica automáticamente
```bash
# Verificar permisos del script auto-apply
ls -la /home/dreamcoder08/Documentos/PROYECTOS/Arch_Dream08/modules/core/zsh/auto-apply-root.sh

# Aplicar manualmente
sudo /home/dreamcoder08/Documentos/PROYECTOS/Arch_Dream08/modules/core/zsh/auto-apply-root.sh
```

### Zsh no es el shell predeterminado
```bash
# Como root, cambiar shell
chsh -s /usr/bin/zsh root
```

### Herramientas opcionales no disponibles
```bash
# Instalar herramientas recomendadas
pacman -S eza bat btop nvim ripgrep fd
```

## 🚨 Consideraciones de Seguridad

1. **Confirmaciones**: Todos los comandos destructivos requieren confirmación
2. **Preserve Root**: Protección contra operaciones en el directorio raíz
3. **Historial**: Configurado para evitar duplicados y comandos sensibles
4. **Prompt**: Identificación visual clara de la sesión root

## 🤝 Contribuir

Para mejorar esta configuración:
1. Edita los archivos correspondientes
2. Ejecuta el instalador para probar
3. Documenta los cambios

---

**⚠️ Advertencia**: Esta configuración está optimizada para administradores experimentados. Úsala con responsabilidad.