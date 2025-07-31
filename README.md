# �� Arch Dream Machine

<div align="center">

![Arch Dream Machine](Dreamcoder.jpg)

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Zsh](https://img.shields.io/badge/Zsh-FF6C6B?style=for-the-badge&logo=zsh&logoColor=white)](https://www.zsh.org/)

[![GitHub stars](https://img.shields.io/github/stars/Albert-fer02/Arch_Dream08?style=social)](https://github.com/Albert-fer02/Arch_Dream08/stargazers)
[![GitHub license](https://img.shields.io/github/license/Albert-fer02/Arch_Dream08)](https://github.com/Albert-fer02/Arch_Dream08/blob/main/LICENSE)

**Script interactivo que configura Arch Linux con herramientas de desarrollo optimizadas**

</div>

---

## 🎯 ¿Qué hace?

Configura automáticamente tu Arch Linux con:
- **Zsh + Oh My Zsh + Powerlevel10k** - Shell mejorado
- **Kitty Terminal** - Terminal con aceleración GPU
- **Fastfetch** - Información del sistema con temas
- **Nano/Neovim** - Editores configurados
- **Git** - Configuración con aliases útiles

## 🚀 Instalación

```bash
# Clonar y ejecutar
git clone https://github.com/Albert-fer02/Arch_Dream08.git
cd Arch_Dream08
./arch-dream.sh
```

**Eso es todo.** El script te guía interactivamente.

## 📋 Módulos Disponibles

| Módulo | Descripción | Estado |
|--------|-------------|--------|
| `zsh` | Shell mejorado con Powerlevel10k | ✅ |
| `kitty` | Terminal con aceleración GPU | ✅ |
| `fastfetch` | Info del sistema con temas | ✅ |
| `nano` | Editor con configuración | ✅ |
| `git` | Git con aliases útiles | ✅ |
| `neovim` | Editor avanzado | ✅ |

## 🎮 Uso

### **Modo Interactivo (Recomendado)**
```bash
./arch-dream.sh
```
- Selecciona opciones del menú
- El script te guía paso a paso

### **Comandos Directos**
```bash
./arch-dream.sh install          # Instalar todo
./arch-dream.sh install zsh      # Instalar solo Zsh
./arch-dream.sh verify           # Verificar instalación
./arch-dream.sh update           # Actualizar módulos
./arch-dream.sh list             # Ver módulos disponibles
```

## 🛠️ Características

- **✅ Interfaz interactiva** - Menús fáciles de usar
- **✅ Instalación modular** - Instala solo lo que necesites
- **✅ Verificación automática** - Confirma que todo funciona
- **✅ Herramientas de mantenimiento** - Limpieza y optimización
- **✅ Barras de progreso** - Visual feedback durante instalación

## 🔧 Mantenimiento

```bash
./arch-dream.sh
# Opción 9 → Modo mantenimiento
```

- Limpiar cache de pacman
- Remover paquetes huérfanos
- Optimizar base de datos
- Actualizar mirrorlist

## 🆘 Problemas Comunes

### **Fuentes no se ven bien**
```bash
sudo pacman -S ttf-meslo-nerd-font-powerlevel10k
```

### **Zsh no funciona**
```bash
./arch-dream.sh verify zsh
./arch-dream.sh install zsh
```

### **Terminal lento**
```bash
./arch-dream.sh
# Opción 7 → Pruebas rápidas
# Opción 9 → Modo mantenimiento
```

## 📁 Estructura

```
Arch_Dream08/
├── arch-dream.sh          # Script principal
├── modules.json           # Configuración de módulos
├── lib/common.sh          # Funciones comunes
├── modules/               # Configuraciones de módulos
│   ├── core/             # zsh, bash
│   ├── terminal/         # kitty
│   ├── tools/            # fastfetch, nano
│   └── development/      # git, neovim
└── docs/                 # Documentación
```

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcion`)
3. Commit tus cambios (`git commit -am 'Agregar nueva función'`)
4. Push a la rama (`git push origin feature/nueva-funcion`)
5. Abre un Pull Request

## 📄 Licencia

MIT License © 2024 **Dreamcoder08**

---

<div align="center">

**¿Te gustó? ¡Deja una ⭐ en el repositorio!**

[![GitHub stars](https://img.shields.io/github/stars/Albert-fer02/Arch_Dream08?style=social)](https://github.com/Albert-fer02/Arch_Dream08/stargazers)

</div>

