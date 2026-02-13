# NvChad Configuration

Esta carpeta debe contener tu configuración completa de NvChad.

## 📋 Cómo copiar tu configuración

```bash
# Copiar toda tu configuración de NvChad al repositorio
cp -r ~/.config/nvim/* ~/dotfiles/config/nvim/
```

## 🎨 Personalizaciones Comunes

Si has personalizado NvChad, probablemente tengas cambios en:

- `lua/custom/` - Configuraciones personalizadas
- `lua/custom/init.lua` - Inicialización custom
- `lua/custom/chadrc.lua` - Configuración de temas y UI
- `lua/custom/configs/` - Configuraciones de plugins
- `lua/custom/mappings.lua` - Keybindings personalizados
- `lua/custom/plugins.lua` - Plugins adicionales

## ⚠️ Nota Importante

El script de instalación (`install.sh`) instalará NvChad desde cero si no existe.
Si ya tienes NvChad instalado, el script copiará tus configuraciones personalizadas.

## 🔧 Primeros pasos después de instalar

Después de ejecutar el instalador, abre nvim y ejecuta:

```vim
:MasonInstallAll
```

Esto instalará todos los Language Servers que hayas configurado.
