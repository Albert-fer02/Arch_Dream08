# 🧩 Arch Dream Machine - Root Configuration

## 📋 Descripción

Este módulo proporciona una configuración personalizada para el superusuario (root) que incluye:

- **Powerlevel10k**: El mismo tema visual que el usuario normal
- **Sin Fastfetch**: Eliminación del lanzador automático de fastfetch
- **Configuración optimizada**: Adaptada específicamente para el entorno de superusuario
- **Indicadores visuales**: Prompt con símbolo '#' para indicar privilegios elevados

## 🚀 Instalación

### Instalación Automática (Recomendada)

La configuración de root se instala automáticamente cuando ejecutas el script principal:

```bash
# Instalar todo el entorno (incluye configuración de root)
./install.sh
```

### Instalación Manual

Si prefieres instalar solo la configuración de root manualmente:

```bash
# 1. Copiar configuración de Bash
sudo cp modules/core/bash/bashrc.root /root/.bashrc

# 2. Copiar configuración de Zsh
sudo cp modules/core/zsh/zshrc.root /root/.zshrc

# 3. Copiar configuración de Powerlevel10k
sudo cp modules/core/zsh/p10k.root.zsh /root/.p10k.zsh

# 4. Establecer permisos correctos
sudo chmod 644 /root/.bashrc /root/.zshrc /root/.p10k.zsh
```

## 🗑️ Desinstalación

### Desinstalación Manual

```bash
# Eliminar archivos de configuración
sudo rm /root/.bashrc /root/.zshrc /root/.p10k.zsh
```

## 🔧 Características

### ✅ Incluido

- **Powerlevel10k**: Tema visual completo con glassmorphism
- **Aliases útiles**: Comandos abreviados para tareas comunes
- **Funciones avanzadas**: Herramientas de productividad
- **Completación inteligente**: Autocompletado mejorado
- **Historial optimizado**: Configuración de historial de comandos
- **Indicadores de seguridad**: Prompt que claramente indica modo root

### ❌ Excluido

- **Fastfetch automático**: No se ejecuta al iniciar sesión
- **Configuraciones de usuario**: Adaptado para entorno de superusuario
- **Rutas de usuario**: Todas las rutas apuntan a `/root/`

## 🎨 Personalizaciones

### Prompt de Root

El prompt de root está configurado para:

- Usar el símbolo `#` en lugar de `❯`
- Mostrar colores de advertencia (rojo) para indicar privilegios elevados
- Mantener el mismo estilo visual que el usuario normal
- Incluir indicadores de seguridad

### Colores Adaptados

- **OS Icon**: Color rojo para indicar modo root
- **Prompt Char**: Color rojo para el símbolo `#`
- **Mensajes de bienvenida**: Advertencias sobre el uso de comandos

## 🔍 Verificación

Para verificar que la instalación fue exitosa:

```bash
# 1. Cambiar a superusuario
sudo su

# 2. Verificar que el prompt tenga el estilo de Powerlevel10k
#    Deberías ver un prompt con glassmorphism y el símbolo #

# 3. Confirmar que no se ejecute fastfetch automáticamente
#    No debería aparecer la información del sistema al iniciar

# 4. Probar algunos comandos
ls -la
pwd
```

## ⚠️ Notas Importantes

### Seguridad

- **Siempre verifica comandos**: El modo root tiene privilegios completos
- **Usa `exit` para salir**: Para volver al usuario normal
- **Revisa rutas**: Asegúrate de estar en el directorio correcto

### Compatibilidad

- **Requiere Powerlevel10k**: Debe estar instalado en el sistema
- **Requiere Oh-My-Zsh**: Para funcionalidad completa de Zsh
- **Requiere Nerd Fonts**: Para iconos correctos

### Rendimiento

- **Carga rápida**: Configuración optimizada para inicio rápido
- **Sin fastfetch**: Elimina la demora del lanzador automático
- **Memoria eficiente**: Configuración ligera

## 🛠️ Solución de Problemas

### Problema: No aparece el tema de Powerlevel10k

```bash
# Verificar que Powerlevel10k esté instalado
ls /usr/share/zsh-themes/powerlevel10k/

# Si no está instalado, instalarlo
sudo pacman -S zsh-theme-powerlevel10k
```

### Problema: Error de permisos

```bash
# Verificar permisos de archivos
ls -la /root/.zshrc /root/.bashrc /root/.p10k.zsh

# Corregir permisos si es necesario
sudo chmod 644 /root/.zshrc /root/.bashrc /root/.p10k.zsh
```

### Problema: Fastfetch sigue ejecutándose

```bash
# Verificar que se copió la configuración correcta
grep -n "fastfetch" /root/.zshrc

# Si aparece, reinstalar la configuración manualmente
sudo cp modules/core/zsh/zshrc.root /root/.zshrc
sudo chmod 644 /root/.zshrc
```

## 📁 Estructura de Archivos

```
modules/core/
├── bash/
│   ├── bashrc          # Configuración de Bash para usuario normal
│   ├── bashrc.root     # Configuración de Bash para root
│   └── install.sh      # Instalador de Bash
├── zsh/
│   ├── zshrc           # Configuración de Zsh para usuario normal
│   ├── zshrc.root      # Configuración de Zsh para root
│   ├── p10k.zsh        # Configuración de Powerlevel10k para usuario normal
│   ├── p10k.root.zsh   # Configuración de Powerlevel10k para root
│   └── install.sh      # Instalador de Zsh
└── README-ROOT-CONFIG.md   # Este archivo
```

**Nota**: La configuración de root se instala automáticamente desde el script principal `install.sh`.

## 🤝 Contribución

Para contribuir a la configuración de root:

1. Modifica los archivos de configuración en `modules/core/`
2. Prueba los cambios con `sudo su`
3. Actualiza la documentación si es necesario
4. Envía un pull request

## 📞 Soporte

Si tienes problemas con la configuración de root:

1. Revisa esta documentación
2. Verifica la sección de solución de problemas
3. Abre un issue en el repositorio
4. Incluye información sobre tu sistema y el error específico

---

**Nota**: Esta configuración está diseñada para proporcionar una experiencia consistente entre el usuario normal y el superusuario, manteniendo la seguridad y funcionalidad apropiadas para cada entorno. 