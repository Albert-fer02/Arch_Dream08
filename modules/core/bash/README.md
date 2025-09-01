# 🚀 Bash Configuration - Arch Dream

Configuración optimizada de Bash para Arch Linux - **simple, rápida y práctica**.

## ✨ Características

### 🔧 **Configuración Base**
- Variables de entorno optimizadas para Arch Linux
- Historial inteligente con eliminación de duplicados
- Navegación mejorada con autocompletion
- Prompt limpio y funcional

### 📂 **Aliases Útiles**
- **Navegación**: `..`, `...`, `-`
- **Archivos**: `ll`, `la` (con eza si está disponible)
- **Sistema**: `df`, `free`, `ports`, `services`
- **Pacman**: `pacs`, `paci`, `pacu`, `paco` (limpiar huérfanos)
- **Git**: `g`, `gs`, `ga`, `gc`, `gp`, `glog`

### ⚡ **Funciones Integradas**
- `mkcd <dir>` - Crear directorio y entrar
- `extract <file>` - Extraer cualquier formato comprimido
- `backup <file>` - Backup con timestamp automático
- `sysinfo` - Información completa del sistema

### 🎨 **Herramientas Modernas**
- Soporte automático para: `eza`, `bat`, `btop`, `rg`, `fd`
- Integración con FZF si está disponible
- Completion avanzado
- Fastfetch en primera carga

## 📦 Instalación

```bash
# Instalar automáticamente
./install.sh

# O manualmente
cp .bashrc ~/.bashrc
source ~/.bashrc
```

## 🔧 Personalización

La configuración está en un solo archivo `~/.bashrc` - fácil de personalizar:

```bash
# Añadir tus aliases personalizados al final
alias mi-comando='comando personalizado'

# Tus funciones personalizadas
mi_funcion() {
    echo "Mi función"
}
```

## 💡 Herramientas Recomendadas

```bash
# Instalar herramientas modernas opcionales
sudo pacman -S eza bat btop ripgrep fd fzf bash-completion
```

## 🚀 Uso

Después de la instalación:

1. **Reiniciar terminal**: `exec bash` o `source ~/.bashrc`
2. **Cambiar shell por defecto**: `chsh -s $(which bash)`
3. **Explorar aliases**: `alias | grep -E "(ls|git|pac)"`

## 📋 Verificación

```bash
# Verificar configuración
bash -n ~/.bashrc

# Ver variables de Arch Dream
echo $ARCH_DREAM_VERSION
echo $ARCH_DREAM_PROFILE
```

---

**🎯 Filosofía**: Máxima funcionalidad con mínima complejidad - ideal para Arch Linux.