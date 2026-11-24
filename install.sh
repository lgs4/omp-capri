#!/usr/bin/env bash
# Instala o tema Capri Afterdark e, por padrão, a personalidade Capri no OMP.
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: ./install.sh [--theme-only] [--help]

  --theme-only  Instala apenas o tema e as preferências visuais.
  --help        Mostra esta ajuda.
EOF
}

install_agent=true

while (($#)); do
  case "$1" in
    --theme-only)
      install_agent=false
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
theme_file="$theme_dir/capri-afterdark.json"
agents_file="$agent_dir/AGENTS.md"
config_file="$agent_dir/config.yml"
backup_dir=''
changed=false

export PI_CODING_AGENT_DIR="$agent_dir"

ensure_backup_dir() {
  if [[ -z "$backup_dir" ]]; then
    backup_dir="$agent_dir/backups/capri-afterdark-$(date +%Y%m%d-%H%M%S)"
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

mkdir -p "$theme_dir"
install_if_changed "$src_dir/themes/capri-afterdark.json" "$theme_file" 'capri-afterdark.json'

if [[ "$install_agent" == true ]]; then
  install_agents_file
fi

current_theme="$(omp config get theme.dark 2>/dev/null || true)"
current_symbols="$(omp config get symbolPreset 2>/dev/null || true)"

if [[ "$current_theme" != 'capri-afterdark' || "$current_symbols" != 'ascii' ]]; then
  backup_file "$config_file" 'config.yml'
fi

if [[ "$current_theme" != 'capri-afterdark' ]]; then
  omp config set theme.dark capri-afterdark >/dev/null
  changed=true
fi

if [[ "$current_symbols" != 'ascii' ]]; then
  omp config set symbolPreset ascii >/dev/null
  changed=true
fi

if [[ "$changed" == true ]]; then
  printf 'Capri Afterdark instalado em %s\n' "$agent_dir"
  if [[ -n "$backup_dir" ]]; then
    printf 'Backup: %s\n' "$backup_dir"
  fi
else
  printf 'Capri Afterdark já estava atualizado em %s\n' "$agent_dir"
fi

if [[ "$install_agent" == true ]]; then
  printf 'A personalidade Capri será carregada em novas sessões do OMP.\n'
fi
