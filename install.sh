#!/bin/bash

if [[ ${UID} -eq 0 ]]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="${HOME}/.icons"
fi

declare SRC_DIR
SRC_DIR=$(cd "$(dirname "${0}")" && pwd)

declare -r COLOR_VARIANTS=("standard" "doder" "ruby" "sun")

function usage {
  printf "%s\n" "Usage: $0 [OPTIONS...] [COLOR VARIANTS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-a" "Install all color folder versions"
  printf "  %-25s%s\n" "-d DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n NAME" "Specify theme name (Default: Vimix)"
  printf "  %-25s%s\n" "-h" "Show this help"
  printf "\n%s\n" "COLOR VARIANTS:"
  printf "  %-25s%s\n" "standard" "Standard color folder version"
  printf "  %-25s%s\n" "doder" "Blue color folder version"
  printf "  %-25s%s\n" "ruby" "Red color folder version"
  printf "  %-25s%s\n" "sun" "Sun color folder version"
  printf "\n  %s\n" "By default, only the standard one is selected."
}

function install_theme {
  case "$1" in
    standard)
      local -r theme_color='#fc9867'
      ;;
    doder)
      local -r theme_color='#4285F4'
      ;;
    ruby)
      local -r theme_color='#F0544C'
      ;;
    sun)
      local -r theme_color='#adbf04'
      ;;
  esac

  # Appends a dash if the variables are not empty
  if [[ "${1}" != "standard" ]]; then
    local -r colorprefix="-${1}"
  fi

  local -r brightprefix="${2:+-$2}"

  local -r THEME_NAME="${NAME}${colorprefix}${brightprefix}"
  local -r THEME_DIR="${DEST_DIR}/${THEME_NAME}"

  if [[ -d "${THEME_DIR}" ]]; then
    rm -rf "${THEME_DIR}"
  fi

  echo "Installing '${THEME_NAME}'..."

  install -d "${THEME_DIR}"

  install -m644 "${SRC_DIR}/src/index.theme" "${THEME_DIR}"

  # Update the name in index.theme
  sed -i "s/%NAME%/${THEME_NAME}/g" "${THEME_DIR}/index.theme"

  if [[ -z "${brightprefix}" ]]; then
    cp -r "${SRC_DIR}"/src/{16,22,24,32,scalable,symbolic} "${THEME_DIR}"
    sed -i "s/#5294e2/$theme_color/g" "${THEME_DIR}"/16/places/*
    cp -r "${SRC_DIR}"/links/{16,22,24,32,scalable,symbolic} "${THEME_DIR}"
    if [[ -n "${colorprefix}" ]]; then
      install -m644 "${SRC_DIR}"/src/colors/color"${colorprefix}"/*.svg "${THEME_DIR}/scalable/places"
    fi

    # Change icon color for dark theme
    sed -i "s/#565656/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/actions/*
    sed -i "s/#727272/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/{places,devices}/*
    sed -i "s/#5294e2/$theme_color/g" "${THEME_DIR}"/16/places/*

  fi

  ln -sr "${THEME_DIR}/16" "${THEME_DIR}/16@2x"
  ln -sr "${THEME_DIR}/22" "${THEME_DIR}/22@2x"
  ln -sr "${THEME_DIR}/24" "${THEME_DIR}/24@2x"
  ln -sr "${THEME_DIR}/32" "${THEME_DIR}/32@2x"
  ln -sr "${THEME_DIR}/scalable" "${THEME_DIR}/scalable@2x"

  cp -r "${SRC_DIR}/src/cursors/dist${brightprefix}" "${THEME_DIR}/cursors"
  gtk-update-icon-cache "${THEME_DIR}"
}

function clean_old_theme {
  rm -rf "${DEST_DIR}"/simple{'-doder','-ruby','-sun'}
}

while [[ $# -gt 0 ]]; do
  if [[ "${1}" = "-a" ]]; then
    colors=("${COLOR_VARIANTS[@]}")
  elif [[ "${1}" = "-d" ]]; then
    DEST_DIR="${2}"
    shift 2
  elif [[ "${1}" = "-n" ]]; then
    NAME="${2}"
    shift 2
  elif [[ "${1}" = "-h" ]]; then
    usage
    exit 0
  # If the argument is a color variant, append it to the colors to be installed
  elif [[ " ${COLOR_VARIANTS[*]} " = *" ${1} "* ]] &&
    [[ "${colors[*]}" != *${1}* ]]; then
    colors+=("${1}")
  else
    echo "ERROR: Unrecognized installation option '${1}'."
    echo "Try '$0 -h' for more information."
    exit 1
  fi

  shift
done

# Default name is ''
: "${NAME:=simple}"

clean_old_theme

# By default, only the standard color variant is selected
for color in "${colors[@]:-standard}"; do
    install_theme "${color}" "${bright}"
done

# EOF
