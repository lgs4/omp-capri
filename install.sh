#!/usr/bin/env bash
# Instala os temas Capri Afterdark e, por padrão, a personalidade Capri no OMP.
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: ./install.sh [--deck-lcd] [--theme-only] [--no-konsole-default] [--help]

  --deck-lcd            Usa a variante para Steam Deck LCD e instala o perfil do Konsole.
  --theme-only          Instala apenas o tema e as preferências visuais.
  --no-konsole-default  Instala o perfil do Konsole sem torná-lo o padrão.
  --help                Mostra esta ajuda.
EOF
}

install_agent=true
deck_lcd=false
set_konsole_default=true

while (($#)); do
  case "$1" in
    --deck-lcd)
      deck_lcd=true
      ;;
    --theme-only)
      install_agent=false
      ;;
    --no-konsole-default)
      set_konsole_default=false
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Opção desconhecida: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! command -v omp >/dev/null 2>&1; then
  printf 'Erro: omp não foi encontrado no PATH.\n' >&2
  exit 1
fi

src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
agent_dir="${PI_CODING_AGENT_DIR:-${OMP_HOME:-"$HOME/.omp"}/agent}"
theme_dir="$agent_dir/themes"
agents_file="$agent_dir/AGENTS.md"
config_file="$agent_dir/config.yml"
backup_dir=''
changed=false
konsole_default_ready=false

if [[ "$deck_lcd" == true ]]; then
  theme_name='capri-afterdark-deck-lcd'
else
  theme_name='capri-afterdark'
fi

theme_source="$src_dir/themes/$theme_name.json"
theme_file="$theme_dir/$theme_name.json"
konsole_data_dir="${XDG_DATA_HOME:-"$HOME/.local/share"}/konsole"
konsole_config_dir="${XDG_CONFIG_HOME:-"$HOME/.config"}"
konsole_scheme_file="$konsole_data_dir/CapriAfterdarkDeckLCD.colorscheme"
konsole_profile_file="$konsole_data_dir/CapriAfterdarkDeckLCD.profile"
konsole_config_file="$konsole_config_dir/konsolerc"

export PI_CODING_AGENT_DIR="$agent_dir"

ensure_backup_dir() {
  if [[ -z "$backup_dir" ]]; then
    backup_dir="$agent_dir/backups/$theme_name-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
  fi
}

backup_file() {
  local source_file="$1"
  local backup_name="$2"

  [[ -f "$source_file" ]] || return 0
  ensure_backup_dir
  cp -p "$source_file" "$backup_dir/$backup_name"
}

install_if_changed() {
  local source_file="$1"
  local destination_file="$2"
  local backup_name="$3"

  if [[ -f "$destination_file" ]] && cmp -s "$source_file" "$destination_file"; then
    return 0
  fi

  backup_file "$destination_file" "$backup_name"
  cp "$source_file" "$destination_file"
  chmod 0644 "$destination_file"
  changed=true
}

install_agents_file() {
  local packaged_file="$src_dir/AGENTS.md"
  local temporary_file

  temporary_file="$(mktemp "$agent_dir/.AGENTS.md.capri.XXXXXX")"
  trap 'rm -f "$temporary_file"' RETURN

  if [[ -f "$agents_file" ]]; then
    awk '
      $0 == "<!-- capri-afterdark:start -->" { managed = 1; next }
      $0 == "<!-- capri-afterdark:end -->"   { managed = 0; next }
      !managed { print }
    ' "$agents_file" > "$temporary_file"
  fi

  {
    printf '%s\n' '<!-- capri-afterdark:start -->'
    cat "$packaged_file"
    printf '%s\n' '<!-- capri-afterdark:end -->'
  } >> "$temporary_file"

  if [[ -f "$agents_file" ]] && cmp -s "$temporary_file" "$agents_file"; then
    rm -f "$temporary_file"
    trap - RETURN
    return 0
  fi

  backup_file "$agents_file" 'AGENTS.md'
  mv "$temporary_file" "$agents_file"
  chmod 0644 "$agents_file"
  trap - RETURN
  changed=true
}

configure_konsole_default() {
  local writer=''
  local reader=''
  local current_profile=''
  local profile_filename='CapriAfterdarkDeckLCD.profile'

  if command -v kwriteconfig6 >/dev/null 2>&1; then
    writer='kwriteconfig6'
    reader='kreadconfig6'
  elif command -v kwriteconfig5 >/dev/null 2>&1; then
    writer='kwriteconfig5'
    reader='kreadconfig5'
  else
    printf '%s\n' 'Aviso: kwriteconfig não foi encontrado; o perfil foi instalado, mas não ativado.' >&2
    return 0
  fi

  if command -v "$reader" >/dev/null 2>&1; then
    current_profile="$("$reader" --file konsolerc --group 'Desktop Entry' --key DefaultProfile 2>/dev/null || true)"
  fi

  if [[ "$current_profile" != "$profile_filename" ]]; then
    mkdir -p "$konsole_config_dir"
    backup_file "$konsole_config_file" 'konsolerc'
    "$writer" --file konsolerc --group 'Desktop Entry' --key DefaultProfile "$profile_filename"
    changed=true
  fi

  konsole_default_ready=true
}

mkdir -p "$theme_dir"
install_if_changed "$theme_source" "$theme_file" "$theme_name.json"

if [[ "$install_agent" == true ]]; then
  install_agents_file
fi

if [[ "$deck_lcd" == true ]]; then
  mkdir -p "$konsole_data_dir"
  install_if_changed \
    "$src_dir/konsole/CapriAfterdarkDeckLCD.colorscheme" \
    "$konsole_scheme_file" \
    'CapriAfterdarkDeckLCD.colorscheme'
  install_if_changed \
    "$src_dir/konsole/CapriAfterdarkDeckLCD.profile" \
    "$konsole_profile_file" \
    'CapriAfterdarkDeckLCD.profile'

  if [[ "$set_konsole_default" == true ]]; then
    configure_konsole_default
  fi
fi

current_theme="$(omp config get theme.dark 2>/dev/null || true)"
current_symbols="$(omp config get symbolPreset 2>/dev/null || true)"

if [[ "$current_theme" != "$theme_name" || "$current_symbols" != 'ascii' ]]; then
  backup_file "$config_file" 'config.yml'
fi

if [[ "$current_theme" != "$theme_name" ]]; then
  omp config set theme.dark "$theme_name" >/dev/null
  changed=true
fi

if [[ "$current_symbols" != 'ascii' ]]; then
  omp config set symbolPreset ascii >/dev/null
  changed=true
fi

if [[ "$changed" == true ]]; then
  printf '%s instalado em %s\n' "$theme_name" "$agent_dir"
  if [[ -n "$backup_dir" ]]; then
    printf 'Backup: %s\n' "$backup_dir"
  fi
else
  printf '%s já estava atualizado em %s\n' "$theme_name" "$agent_dir"
fi

if [[ "$deck_lcd" == true ]]; then
  if [[ "$konsole_default_ready" == true ]]; then
    printf '%s\n' 'O perfil Capri Afterdark - Steam Deck LCD será usado por novas janelas do Konsole.'
  else
    printf '%s\n' 'Ative o perfil Capri Afterdark - Steam Deck LCD nas configurações do Konsole.'
  fi
fi

if [[ "$install_agent" == true ]]; then
  printf 'A personalidade Capri será carregada em novas sessões do OMP.\n'
fi
