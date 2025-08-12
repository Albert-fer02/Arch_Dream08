# 🎯 ZSH Red Team Configuration

Configuración ultra-optimizada de ZSH diseñada específicamente para Red Team operations y hacking ético. Incluye Starship prompt, Zinit plugin manager, y herramientas modernas para máxima productividad.

## 🚀 Características

### Core Technologies
- **ZSH** - Shell avanzado con autocompletado inteligente
- **Starship** - Prompt ultra-rápido y personalizable
- **Zinit** - Plugin manager moderno y eficiente

### Plugins Incluidos
- `zsh-users/zsh-autosuggestions` - Sugerencias inteligentes basadas en historial
- `zdharma-continuum/fast-syntax-highlighting` - Resaltado de sintaxis ultra-rápido
- `rupa/z` - Navegación rápida de directorios
- `zdharma-continuum/history-search-multi-word` - Búsqueda avanzada en historial

### Herramientas Modernas
- `bat` - Mejor versión de `cat` con sintaxis highlighting
- `eza` - Mejor versión de `ls` con iconos y git info
- `ripgrep` - Búsqueda ultra-rápida en archivos
- `fd` - Mejor versión de `find`
- `fzf` - Fuzzy finder para todo
- `btop` - Monitor de sistema moderno

## 🎯 Funciones Red Team

### Información de Red
```bash
redteam-info              # Mostrar información completa de red
myip                      # IP pública
localip                   # IP local
```

### Configuración de Objetivo
```bash
set-target 192.168.1.100  # Configurar objetivo
portscan 192.168.1.100    # Escaneo rápido de puertos
```

### Enumeración Web
```bash
direnum http://target.com  # Enumeración de directorios
```

### Encoding/Decoding
```bash
b64e "texto"              # Codificar en base64
b64d "dGV4dG8="           # Decodificar base64
urle "texto con espacios" # URL encode
urld "texto%20encoded"    # URL decode
```

### Hashing
```bash
md5sum "texto"            # Hash MD5
sha1sum "texto"           # Hash SHA1
sha256sum "texto"         # Hash SHA256
```

### Utilidades
```bash
passgen 16                # Generar contraseña de 16 caracteres
backup archivo.txt        # Backup con timestamp
extract archivo.zip       # Extraer cualquier tipo de archivo
```

## 📁 Estructura de Archivos

```
~/.zshrc                  # Configuración principal (NO EDITAR)
~/.zshrc.local           # Configuraciones personales
~/.config/starship.toml  # Configuración del prompt
~/.local/share/zinit/    # Directorio de plugins
~/.zsh/                  # Caché y completions
```

## 🎨 Prompt Red Team

El prompt muestra información crucial para Red Team:

```
╭─👤user@hostname 📁~/project 🌱main ✅ 🏠192.168.1.50 🌐203.0.113.1
╰─➜ 
```

### Elementos del Prompt
- **👤** Usuario y hostname
- **📁** Directorio actual con iconos
- **🌱** Rama de git y estado
- **🏠** IP local (cuando está configurada)
- **🌐** IP pública (cuando está configurada)
- **🎯** Target (cuando está configurado)
- **⏱️** Duración de comandos lentos
- **🧠** Uso de memoria cuando es alto

## 🔧 Instalación

### Automática (Recomendada)
```bash
cd /path/to/Arch_Dream08
./install.sh core:zsh
```

### Manual
```bash
cd modules/core/zsh
./install.sh
```

### Verificación
```bash
./verify-redteam-zsh.sh
```

## ⚙️ Configuración Personalizada

### Variables de Entorno Red Team
Añadir en `~/.zshrc.local`:

```bash
# Target configuration
export TARGET="192.168.1.100"
export PROXY="127.0.0.1:8080"

# Custom paths
export PATH="/opt/custom-tools:$PATH"
```

### Aliases Personalizados
```bash
# Custom aliases
alias target-ssh="ssh user@$TARGET"
alias target-web="firefox http://$TARGET"
alias burp="java -jar /opt/burpsuite/burpsuite.jar"
```

### Funciones Personalizadas
```bash
# Custom function for specific workflow
my-recon() {
    local target="$1"
    echo "🎯 Starting reconnaissance on $target"
    nmap -sn "$target/24"
    nmap -sS -O "$target"
}
```

## 🔍 Troubleshooting

### ZSH no es el shell por defecto
```bash
chsh -s /bin/zsh
```

### Starship no se muestra
```bash
# Verificar instalación
which starship

# Reinstalar si es necesario
curl -sS https://starship.rs/install.sh | sh
```

### Plugins no cargan
```bash
# Limpiar caché de Zinit
rm -rf ~/.local/share/zinit/.zinit
rm -rf ~/.zsh/compdump/*

# Recargar configuración
source ~/.zshrc
```

### Problemas de permisos
```bash
# Reparar permisos
chmod 755 ~/.zsh
chmod 644 ~/.zshrc ~/.zshrc.local
```

## 🎯 Red Team Workflows

### Reconocimiento Inicial
```bash
set-target domain.com
redteam-info
portscan $TARGET
```

### Enumeración Web
```bash
direnum https://$TARGET
gobuster dir -u https://$TARGET -w /usr/share/wordlists/common.txt
```

### Análisis de Red
```bash
nmap-quick $TARGET
nmap-intense $TARGET
```

## 🔒 Seguridad

- Los archivos de configuración no contienen credenciales hardcodeadas
- Variables sensibles deben ir en `~/.zshrc.local` (añadir a .gitignore)
- El historial de comandos se guarda de forma segura
- Funciones de hashing y encoding incluidas

## 📚 Recursos Adicionales

- [Starship Documentation](https://starship.rs/)
- [Zinit Documentation](https://github.com/zdharma-continuum/zinit)
- [ZSH Documentation](https://zsh.sourceforge.io/Doc/)

## 🆘 Soporte

Si encuentras problemas:

1. Ejecuta `./verify-redteam-zsh.sh` para diagnóstico
2. Revisa los logs en `~/.zsh/`
3. Consulta la documentación de cada herramienta
4. Reporta issues en el repositorio del proyecto

---

**💡 Tip**: Usa `reload` para recargar la configuración después de hacer cambios en `~/.zshrc.local`.
