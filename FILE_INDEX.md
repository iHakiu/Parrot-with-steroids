# 📑 Índice de Archivos del Repositorio

Descripción completa de todos los archivos y su propósito en este repositorio.

## 📄 Archivos Principales

| Archivo | Descripción |
|---------|-------------|
| `README.md` | Documentación principal del repositorio con toda la información |
| `SHORTCUTS.md` | Lista completa de atajos de teclado del sistema |
| `QUICKSTART.md` | Guía rápida de inicio para instalación y configuración |
| `SETUP_GUIDE.md` | Guía detallada paso a paso para configurar el repositorio |
| `MISSING_FILES.md` | Lista de archivos que debes copiar desde tu sistema |
| `FILE_INDEX.md` | Este archivo - índice de todos los archivos |
| `.gitignore` | Archivos que Git debe ignorar |

## 🖼️ Assets (Imágenes)

```
assets/
├── README.md           # Instrucciones sobre las imágenes
├── preview.png         # Imagen principal del README (DEBES AÑADIRLA)
└── screenshots/        # Capturas adicionales (OPCIONALES)
    ├── polybar.png
    ├── rofi.png
    ├── terminal.png
    └── ...
```

**Nota:** Lee [assets/README.md](assets/README.md) para saber cómo hacer y subir las capturas.

## 🔧 Scripts de Automatización

| Script | Propósito |
|--------|-----------|
| `install.sh` | **Script principal** - Instala todo automáticamente en un sistema nuevo |
| `verify.sh` | Verifica que todos los archivos necesarios estén presentes |
| `copy_configs.sh` | Ayuda a copiar todas tus configuraciones actuales al repo |

**Uso de scripts:**
```bash
chmod +x install.sh verify.sh copy_configs.sh
./install.sh      # Para instalar en sistema nuevo
./verify.sh       # Para verificar archivos
./copy_configs.sh # Para copiar tus configs al repo
```

## 📁 Configuraciones por Aplicación

### BSPWM
```
config/bspwm/
├── bspwmrc                      # Configuración principal de BSPWM
└── scripts/
    ├── ethernet_status.sh       # [INCLUIDO] Muestra IP local
    ├── htb_ip.sh               # [INCLUIDO] Muestra IP VPN HTB
    └── target_hack.sh          # [INCLUIDO] Muestra target actual
```

### SXHKD
```
config/sxhkd/
└── sxhkdrc                     # [DEBES COPIAR] Tus atajos de teclado
```

### Polybar
```
config/polybar/
├── config.ini                  # [INCLUIDO/EJEMPLO] Configuración de polybar
└── launch.sh                   # [INCLUIDO] Script para lanzar polybar
```

### Picom
```
config/picom/
└── picom.conf                  # [INCLUIDO/EJEMPLO] Configuración de compositor
```

### Rofi
```
config/rofi/
├── config.rasi                 # [DEBES COPIAR] Tu configuración
└── themes/                     # [OPCIONAL] Temas personalizados
```

### Kitty
```
config/kitty/
└── kitty.conf                  # [DEBES COPIAR] Tu configuración
```

### ZSH
```
config/zsh/
├── .zshrc                      # [INCLUIDO/EJEMPLO] Config con funciones custom
└── .p10k.zsh                   # [DEBES COPIAR] Tu configuración de p10k
```

**Funciones custom incluidas en .zshrc:**
- `settarget <IP>` - Establece target de máquina
- `cleartarget` - Limpia el target
- `mkt <nombre>` - Crea estructura de directorios para CTF

### NvChad
```
config/nvim/
├── README.md                   # [INCLUIDO] Instrucciones para NvChad
└── [TUS ARCHIVOS]             # [DEBES COPIAR] Toda tu config personalizada
```

### Wallpapers
```
wallpapers/
├── README.md                   # [INCLUIDO] Instrucciones para wallpapers
└── fondo.jpg                   # [DEBES COPIAR] Tu wallpaper principal
```

## 🎯 Archivos que DEBES Copiar

Estos archivos **NO están incluidos** y debes copiarlos desde tu sistema:

- ✗ `config/bspwm/bspwmrc`
- ✗ `config/sxhkd/sxhkdrc`
- ✗ `config/rofi/config.rasi`
- ✗ `config/kitty/kitty.conf`
- ✗ `config/zsh/.p10k.zsh`
- ✗ `config/nvim/*` (toda la carpeta)
- ✗ `wallpapers/fondo.jpg`

**Solución rápida:** Ejecuta `./copy_configs.sh`

## ✅ Archivos YA Incluidos

Estos archivos ya están en el repositorio y son funcionales:

- ✓ `install.sh` - Instalador completo
- ✓ `config/bspwm/scripts/*` - Scripts de polybar
- ✓ `config/polybar/config.ini` - Config de ejemplo
- ✓ `config/polybar/launch.sh` - Launcher
- ✓ `config/picom/picom.conf` - Config con transparencias
- ✓ `config/zsh/.zshrc` - Config con funciones custom

## 🔄 Flujo de Trabajo

### Configurar el Repositorio (Primera vez)
```
1. Clonar/crear repo
2. Ejecutar: ./copy_configs.sh
3. Ejecutar: ./verify.sh
4. Personalizar si es necesario
5. git add . && git commit && git push
```

### Instalar en Sistema Nuevo
```
1. git clone [tu-repo]
2. cd dotfiles
3. ./install.sh
4. Reiniciar sesión
5. ¡Listo!
```

### Actualizar Configuraciones
```
1. Hacer cambios en tu sistema
2. cd ~/dotfiles
3. ./copy_configs.sh (opcional)
4. git add . && git commit && git push
```

## 📊 Resumen de Archivos

- **Total de scripts:** 3 (install.sh, verify.sh, copy_configs.sh)
- **Total de docs:** 5 (README, QUICKSTART, SETUP_GUIDE, etc.)
- **Configs incluidas:** 4 (polybar, picom, zsh, scripts)
- **Configs a copiar:** 7 (bspwm, sxhkd, rofi, kitty, p10k, nvim, wallpaper)

## 🔗 Enlaces Rápidos a Archivos

- [README Principal](README.md) - Documentación completa
- [Guía Rápida](QUICKSTART.md) - Instalación express
- [Guía de Setup](SETUP_GUIDE.md) - Configuración detallada
- [Archivos Faltantes](MISSING_FILES.md) - Qué copiar
- [Script Instalador](install.sh) - Instalación automática
- [Script Verificador](verify.sh) - Verificar archivos
- [Script Copiador](copy_configs.sh) - Copiar configs

---

**¿Perdido?** Lee el [README.md](README.md) o el [QUICKSTART.md](QUICKSTART.md) 🚀
