# 🔧 Arch Dream Machine - Guía de Troubleshooting

## 📋 Índice

1. [Problemas Comunes](#problemas-comunes)
2. [Problemas de Rendimiento](#problemas-de-rendimiento)
3. [Problemas de Configuración](#problemas-de-configuración)
4. [Problemas de Fuentes](#problemas-de-fuentes)
5. [Problemas de Paquetes](#problemas-de-paquetes)
6. [Problemas de Permisos](#problemas-de-permisos)
7. [Problemas de Red](#problemas-de-red)
8. [Recuperación de Errores](#recuperación-de-errores)
9. [Debugging Avanzado](#debugging-avanzado)

---

## 🚨 Problemas Comunes

### Zsh no se carga correctamente

**Síntomas:**
- Prompt básico sin colores
- Sin autocompletado
- Sin sugerencias

**Soluciones:**

1. **Verificar instalación de Oh My Zsh:**
   ```bash
   ls -la ~/.oh-my-zsh
   ```

2. **Reinstalar Oh My Zsh:**
   ```bash
   rm -rf ~/.oh-my-zsh
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
   ```

3. **Verificar plugins:**
   ```bash
   ls -la /usr/share/zsh/plugins/
   ```

4. **Recargar configuración:**
   ```bash
   source ~/.zshrc
   ```

### Powerlevel10k no funciona

**Síntomas:**
- Prompt básico
- Sin iconos
- Sin colores

**Soluciones:**

1. **Verificar instalación:**
   ```bash
   ls -la ~/.oh-my-zsh/custom/themes/powerlevel10k
   ```

2. **Reinstalar Powerlevel10k:**
   ```bash
   rm -rf ~/.oh-my-zsh/custom/themes/powerlevel10k
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
   ```

3. **Reconfigurar:**
   ```bash
   p10k configure
   ```

4. **Verificar tema en .zshrc:**
   ```bash
   grep "ZSH_THEME" ~/.zshrc
   ```

### Kitty no inicia

**Síntomas:**
- Error al abrir Kitty
- Ventana en blanco
- Crashes

**Soluciones:**

1. **Verificar instalación:**
   ```bash
   kitty --version
   ```

2. **Verificar configuración:**
   ```bash
   kitty --config-file ~/.config/kitty/kitty.conf
   ```

3. **Probar con configuración mínima:**
   ```bash
   kitty --config-file /dev/null
   ```

4. **Verificar fuentes:**
   ```bash
   fc-list | grep -i "meslo"
   ```

---

## ⚡ Problemas de Rendimiento

### Zsh lento al iniciar

**Síntomas:**
- Tiempo de carga largo
- Delay en el prompt
- Comandos lentos

**Soluciones:**

1. **Optimizar .zshrc:**
   ```bash
   # Agregar al inicio de .zshrc
   DISABLE_AUTO_UPDATE="true"
   DISABLE_UPDATE_PROMPT="true"
   DISABLE_UNTRACKED_FILES_DIRTY="true"
   ```

2. **Reducir plugins:**
   ```bash
   # Comentar plugins innecesarios en .zshrc
   plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
   ```

3. **Limpiar cache:**
   ```bash
   rm -rf ~/.zsh/cache
   rm -rf ~/.cache/zsh
   ```

4. **Verificar archivos grandes:**
   ```bash
   find ~ -name "*.zsh_history" -size +10M
   ```

### Kitty lento

**Síntomas:**
- Renderizado lento
- Input lag
- Alto uso de CPU

**Soluciones:**

1. **Habilitar aceleración GPU:**
   ```bash
   # En kitty.conf
   gpu_acceleration on
   ```

2. **Optimizar configuración:**
   ```bash
   # Reducir repaint_delay
   repaint_delay 10
   input_delay 3
   ```

3. **Verificar drivers:**
   ```bash
   glxinfo | grep "OpenGL renderer"
   ```

4. **Probar con configuración mínima:**
   ```bash
   kitty --config-file /dev/null
   ```

---

## ⚙️ Problemas de Configuración

### Symlinks rotos

**Síntomas:**
- Archivos de configuración no encontrados
- Errores de "No such file or directory"

**Soluciones:**

1. **Verificar symlinks:**
   ```bash
   ls -la ~/.zshrc ~/.p10k.zsh ~/.bashrc
   ```

2. **Recrear symlinks:**
   ```bash
   ./install.sh --dry-run
   ```

3. **Verificar rutas:**
   ```bash
   readlink ~/.zshrc
   ```

4. **Reparar manualmente:**
   ```bash
   ln -sf /ruta/correcta/zshrc ~/.zshrc
   ```

### Configuración no se aplica

**Síntomas:**
- Cambios no visibles
- Configuración antigua persiste

**Soluciones:**

1. **Recargar configuración:**
   ```bash
   source ~/.zshrc
   ```

2. **Reiniciar terminal:**
   ```bash
   # Cerrar y abrir nueva terminal
   ```

3. **Verificar permisos:**
   ```bash
   ls -la ~/.zshrc
   ```

4. **Limpiar cache:**
   ```bash
   rm -rf ~/.zsh/cache
   ```

---

## 🔤 Problemas de Fuentes

### Iconos no se muestran

**Síntomas:**
- Cuadrados en lugar de iconos
- Caracteres extraños
- Iconos faltantes

**Soluciones:**

1. **Verificar fuentes Nerd Font:**
   ```bash
   fc-list | grep -i "nerd"
   ```

2. **Instalar fuentes:**
   ```bash
   sudo pacman -S ttf-meslo-nerd-font-powerlevel10k
   ```

3. **Configurar fuente en Kitty:**
   ```bash
   # En kitty.conf
   font_family MesloLGS NF
   ```

4. **Actualizar cache de fuentes:**
   ```bash
   fc-cache -fv
   ```

### Fuentes incorrectas

**Síntomas:**
- Texto pixelado
- Tamaño incorrecto
- Fuente no aplicada

**Soluciones:**

1. **Verificar configuración:**
   ```bash
   grep "font_family" ~/.config/kitty/kitty.conf
   ```

2. **Probar fuentes:**
   ```bash
   kitty +kitten font-list
   ```

3. **Configurar fuente correcta:**
   ```bash
   # En kitty.conf
   font_family MesloLGS NF
   font_size 12.5
   ```

4. **Reiniciar Kitty:**
   ```bash
   # Cerrar y abrir Kitty
   ```

---

## 📦 Problemas de Paquetes

### Paquetes no encontrados

**Síntomas:**
- Error "Package not found"
- Paquetes faltantes

**Soluciones:**

1. **Actualizar base de datos:**
   ```bash
   sudo pacman -Sy
   ```

2. **Verificar repositorios:**
   ```bash
   sudo pacman -Syy
   ```

3. **Buscar paquetes:**
   ```bash
   pacman -Ss nombre_paquete
   ```

4. **Instalar desde AUR:**
   ```bash
   yay -S nombre_paquete
   # o
   paru -S nombre_paquete
   ```

### Conflictos de paquetes

**Síntomas:**
- Error de dependencias
- Paquetes rotos

**Soluciones:**

1. **Verificar dependencias:**
   ```bash
   sudo pacman -Dk
   ```

2. **Reparar paquetes:**
   ```bash
   sudo pacman -S --overwrite "*"
   ```

3. **Limpiar cache:**
   ```bash
   sudo pacman -Sc
   ```

4. **Reinstalar paquetes:**
   ```bash
   sudo pacman -S --needed paquete
   ```

---

## 🔐 Problemas de Permisos

### Permisos denegados

**Síntomas:**
- "Permission denied"
- No se pueden crear archivos

**Soluciones:**

1. **Verificar permisos:**
   ```bash
   ls -la ~/.zshrc
   ```

2. **Corregir permisos:**
   ```bash
   chmod 644 ~/.zshrc
   ```

3. **Verificar propiedad:**
   ```bash
   ls -la ~/.zshrc
   chown $USER:$USER ~/.zshrc
   ```

4. **Verificar directorio home:**
   ```bash
   ls -la ~/
   ```

### Problemas de sudo

**Síntomas:**
- No se pueden instalar paquetes
- Error de permisos sudo

**Soluciones:**

1. **Verificar grupo sudo:**
   ```bash
   groups $USER
   ```

2. **Agregar usuario a sudo:**
   ```bash
   sudo usermod -aG wheel $USER
   ```

3. **Configurar sudoers:**
   ```bash
   sudo visudo
   ```

4. **Probar sudo:**
   ```bash
   sudo -v
   ```

---

## 🌐 Problemas de Red

### Sin conexión a internet

**Síntomas:**
- No se pueden descargar paquetes
- Error de conexión

**Soluciones:**

1. **Verificar conexión:**
   ```bash
   ping -c 3 archlinux.org
   ```

2. **Verificar DNS:**
   ```bash
   nslookup archlinux.org
   ```

3. **Configurar DNS:**
   ```bash
   echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
   ```

4. **Verificar red:**
   ```bash
   ip addr show
   ```

### Problemas con AUR

**Síntomas:**
- No se pueden instalar paquetes AUR
- Error de git

**Soluciones:**

1. **Verificar AUR helper:**
   ```bash
   yay --version
   # o
   paru --version
   ```

2. **Actualizar AUR helper:**
   ```bash
   yay -Sua
   # o
   paru -Sua
   ```

3. **Configurar git:**
   ```bash
   git config --global user.name "Tu Nombre"
   git config --global user.email "tu@email.com"
   ```

4. **Limpiar cache AUR:**
   ```bash
   yay -Sc
   # o
   paru -Sc
   ```

---

## 🔄 Recuperación de Errores

### Sistema corrupto

**Síntomas:**
- Paquetes rotos
- Sistema inestable

**Soluciones:**

1. **Verificar integridad:**
   ```bash
   sudo pacman -Dk
   ```

2. **Reparar paquetes:**
   ```bash
   sudo pacman -S --overwrite "*"
   ```

3. **Reinstalar paquetes críticos:**
   ```bash
   sudo pacman -S --needed base base-devel
   ```

4. **Restaurar desde backup:**
   ```bash
   # Si tienes backup
   cp -r ~/.config_backup_* ~/.config/
   ```

### Configuración perdida

**Síntomas:**
- Configuración reset
- Archivos faltantes

**Soluciones:**

1. **Verificar backups:**
   ```bash
   ls -la ~/.config_backup_*
   ```

2. **Restaurar configuración:**
   ```bash
   cp -r ~/.config_backup_*/* ~/
   ```

3. **Recrear symlinks:**
   ```bash
   ./install.sh
   ```

4. **Verificar integridad:**
   ```bash
   ./verify.sh
   ```

---

## 🐛 Debugging Avanzado

### Modo verbose

**Habilitar logging detallado:**

1. **Zsh verbose:**
   ```bash
   zsh -xvs
   ```

2. **Kitty verbose:**
   ```bash
   kitty --debug-font-fallback
   ```

3. **Pacman verbose:**
   ```bash
   sudo pacman -S --verbose paquete
   ```

### Logs del sistema

**Verificar logs:**

1. **Logs de sistema:**
   ```bash
   journalctl -xe
   ```

2. **Logs de pacman:**
   ```bash
   tail -f /var/log/pacman.log
   ```

3. **Logs de usuario:**
   ```bash
   tail -f ~/setup_arch_dream.log
   ```

### Herramientas de diagnóstico

**Comandos útiles:**

1. **Información del sistema:**
   ```bash
   fastfetch
   neofetch
   inxi -Fxz
   ```

2. **Información de paquetes:**
   ```bash
   pacman -Qi paquete
   pacman -Ql paquete
   ```

3. **Información de archivos:**
   ```bash
   file ~/.zshrc
   ldd $(which zsh)
   ```

4. **Información de red:**
   ```bash
   ip addr show
   ip route show
   ```

---

## 📞 Soporte

### Información para reportar bugs

**Incluir en reportes:**

1. **Información del sistema:**
   ```bash
   uname -a
   cat /etc/os-release
   ```

2. **Versiones de paquetes:**
   ```bash
   pacman -Q | grep -E "(zsh|kitty|fastfetch)"
   ```

3. **Logs de error:**
   ```bash
   cat ~/setup_arch_dream.log
   ```

4. **Configuración actual:**
   ```bash
   ls -la ~/.zshrc ~/.p10k.zsh ~/.config/kitty/
   ```

### Canales de soporte

- **GitHub Issues:** [Reportar bug](https://github.com/Albert-fer02/arch-dream-machine/issues)
- **Documentación:** [Wiki del proyecto](https://github.com/Albert-fer02/arch-dream-machine/wiki)
- **Comunidad:** [Discord/Telegram]

---

## 🎯 Consejos de Mantenimiento

### Mantenimiento regular

1. **Actualizar sistema semanalmente:**
   ```bash
   ./update.sh
   ```

2. **Verificar integridad mensualmente:**
   ```bash
   ./verify.sh --report
   ```

3. **Limpiar sistema:**
   ```bash
   sudo pacman -Sc
   sudo journalctl --vacuum-time=7d
   ```

4. **Revisar logs:**
   ```bash
   tail -n 50 ~/setup_arch_dream.log
   ```

### Prevención de problemas

1. **Hacer backups regulares:**
   ```bash
   cp -r ~/.config ~/.config_backup_$(date +%Y%m%d)
   ```

2. **Probar cambios en modo dry-run:**
   ```bash
   ./install.sh --dry-run
   ```

3. **Mantener documentación actualizada:**
   ```bash
   # Documentar cambios personalizados
   ```

4. **Monitorear uso de recursos:**
   ```bash
   btop
   htop
   ``` 