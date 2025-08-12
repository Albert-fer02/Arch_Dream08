# Arch Dream Machine

<div align="center">

![Arch Dream Machine](Dreamcoder.jpg)

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Zsh](https://img.shields.io/badge/Zsh-FF6C6B?style=for-the-badge&logo=zsh&logoColor=white)](https://www.zsh.org/)

[![GitHub stars](https://img.shields.io/github/stars/Albert-fer02/Arch_Dream08?style=social)](https://github.com/Albert-fer02/Arch_Dream08/stargazers)
[![GitHub license](https://img.shields.io/github/license/Albert-fer02/Arch_Dream08)](https://github.com/Albert-fer02/Arch_Dream08/blob/main/LICENSE)

**Script ultra optimizado que configura Arch Linux con herramientas de desarrollo de máxima productividad**

</div>

---

## 🎯 ¿Qué hace?

Configura automáticamente tu Arch Linux con configuraciones ultra optimizadas:
- **Zsh + Starship + Zinit** - Shell ultra optimizado (rápido y minimal)
- **Bash mejorado** - Configuración avanzada con herramientas modernas
- **Kitty Terminal** - Terminal con aceleración GPU
- **Fastfetch** - Información del sistema con temas
- **Nano/Neovim** - Editores configurados
- **Git** - Configuración con aliases avanzados
- **Herramientas modernas** - eza, bat, ripgrep, fd, y más

## 🚀 Instalación

```bash
# Clonar y ejecutar
git clone https://github.com/Albert-fer02/Arch_Dream08.git
cd Arch_Dream08

# ⚡ Instalación (Recomendado)
./install.sh -y   # modo no interactivo
```

**¡Eso es todo!** Instalación completa en ~2 minutos.

### 🎨 Instalación Avanzada (Opcional)
```bash
# Para usuarios avanzados que quieren más control
# Los scripts ultra rápidos son suficientes para la mayoría
```

## 📋 Módulos Disponibles

| Módulo | Descripción | Estado |
|--------|-------------|--------|
| `core:zsh` | Zsh con Starship + Zinit (Red Team optimizado) | ✅ |
| `core:bash` | Bash optimizado (prompt Starship/OMP opcional) | ✅ |
| `terminal:kitty` | Terminal con aceleración GPU | ✅ |
| `tools:fastfetch` | Info del sistema con temas | ✅ |
| `tools:nano` | Editor con configuración | ✅ |
| `development:nvim` | Neovim (LazyVim + plugins) | ✅ |

## 🎮 Uso

### **⚡ Instalación (Recomendado)**
```bash
# Instalación completa en ~2 minutos
./install.sh -y
```

### **📋 Comandos Simples**
```bash
./install.sh -y                            # Instalar todo (no interactivo)
./install.sh --modules core:zsh,terminal:kitty   # Instalar solo módulos específicos
./install.sh --skip tools:nano               # Saltar un módulo
./install.sh --copy -y                       # Copiar archivos (sin symlinks)
./install.sh --dry-run                       # Simular instalación
```

**¡Eso es todo!** No necesitas más comandos.

## 🛠️ Características Ultra Optimizadas

- **✅ Instalación ultra rápida** - Todo en ~2 minutos
- **✅ Sin interrupciones** - Instalación completamente automática
- **✅ Herramientas modernas** - eza, bat, ripgrep, fd, fzf, btop
- **✅ Shell optimizado** - Zsh + Oh My Zsh + Powerlevel10k
- **✅ Terminal moderna** - Kitty con aceleración GPU
- **✅ Editores configurados** - Neovim y Nano optimizados
- **✅ Git configurado** - Aliases y configuraciones listas
- **✅ Verificación automática** - Comprueba que todo funciona
- **✅ Rendimiento máximo** - Configuraciones ultra optimizadas
- **✅ Productividad inmediata** - Listo para usar desde el primer momento

## 🔧 Mantenimiento

- Limpiar caché de pacman: `sudo pacman -Sc` (o usa alias `cleanup` en zsh)
- Remover paquetes huérfanos: `pacman -Qtdq | sudo pacman -Rns -`
- Actualizar sistema: `sysupdate`

## 🆘 Problemas Comunes

### **Fuentes no se ven bien**
```bash
sudo pacman -S ttf-meslo-nerd-font-powerlevel10k
```

### **Zsh no funciona**
Ejecuta `exec zsh` tras la instalación o reinicia la terminal. Verifica `which zsh` y `echo $SHELL`.

### **Starship no se inicializa**
Verifica que `~/.config/starship.toml` existe y que `starship` está instalado (`pacman -Q starship`).

### **Terminal lento**
Prueba `btop`, limpia cachés (`clean-*-cache`), y desactiva plugins pesados.

### **Verificar optimizaciones**
```bash
```

## 📁 Estructura

```
Arch_Dream08/
├── install.sh                 # ⚡ Instalador principal
├── modules.json               # Configuración de módulos
├── lib/common.sh              # Funciones comunes
├── modules/                   # Configuraciones de módulos
│   ├── core/                 # zsh, bash (ultra optimizados)
│   ├── terminal/             # kitty
│   ├── tools/                # fastfetch, nano
│   └── development/          # nvim
├── docs/                     # Documentación
│   └── OPTIMIZATIONS.md      # Detalles de optimizaciones
└── README.md                 # Este archivo
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

