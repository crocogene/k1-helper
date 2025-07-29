#!/usr/bin/env bash

set -e
clear

HELPER_SCRIPT_FOLDER="$(dirname "$(readlink -f "$0")")"

for script in "${HELPER_SCRIPT_FOLDER}/scripts/"*.sh; do . "${script}"; done
. "${HELPER_SCRIPT_FOLDER}/scripts/menu/functions.sh"

# custimized copy of scripts/improved_shapers.sh
function install_improved_shapers(){
  improved_shapers_message
  local yn
  while true; do
    install_msg "Improved Shapers Calibrations" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Linking files..."
        ln -sf "$IMP_SHAPERS_URL"/calibrate_shaper_config.py "$KLIPPER_EXTRAS_FOLDER"/calibrate_shaper_config.py
        if [ -f "$HS_CONFIG_FOLDER"/improved-shapers ]; then
          rm -rf "$HS_CONFIG_FOLDER"/improved-shapers
        fi
        if [ ! -d "$HS_CONFIG_FOLDER"/improved-shapers/scripts ]; then
          mkdir -p "$HS_CONFIG_FOLDER"/improved-shapers/scripts
        fi
        cp "$IMP_SHAPERS_URL"/scripts/*.py "$HS_CONFIG_FOLDER"/improved-shapers/scripts
        ln -sf "$IMP_SHAPERS_URL"/improved-shapers.cfg "$HS_CONFIG_FOLDER"/improved-shapers/improved-shapers.cfg
        if grep -q 'variable_autotune_shapers:' "$MACROS_CFG" ; then
          echo -e "Info: Disabling [gcode_macro AUTOTUNE_SHAPERS] configurations in gcode_macro.cfg file..."
          sed -i 's/variable_autotune_shapers:/#&/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro AUTOTUNE_SHAPERS] configurations are already disabled in gcode_macro.cfg file..."
        fi
        if [ "$model" = "K1" ]; then
          if grep -q '\[gcode_macro INPUTSHAPER\]' "$MACROS_CFG" ; then
            echo -e "Info: Replacing [gcode_macro INPUTSHAPER] configurations in gcode_macro.cfg file..."
            sed -i 's/SHAPER_CALIBRATE AXIS=y/SHAPER_CALIBRATE/' "$MACROS_CFG"
          else
            echo -e "Info: [gcode_macro INPUTSHAPER] configurations are already replaced in gcode_macro.cfg file..."
          fi
        fi
        if grep -q "include Helper-Script/improved-shapers/improved-shapers" "$PRINTER_CFG" ; then
          echo -e "Info: Improved Shapers Calibration configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Improved Shapers Calibration configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/improved-shapers/improved-shapers\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Improved Shapers Calibrations have been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

set_paths
install_improved_shapers