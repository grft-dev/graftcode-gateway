#!/usr/bin/env bash
set -euo pipefail

REPO="grft-dev/graftcode-gateway"
EXE_NAME="gg"
OUTPUT_PATH="$PWD/$EXE_NAME"

RULE_DOTNET_URL="https://raw.githubusercontent.com/grft-dev/graftcode-demos/refs/heads/main/rules/Cursor/.cursor/rules/graftcode-dotnet.mdc"
RULE_TS_URL="https://raw.githubusercontent.com/grft-dev/graftcode-demos/refs/heads/main/rules/Cursor/.cursor/rules/graftcode-typescript-node-nextjs.mdc"

show_intro() {
  clear || true

  cat <<'EOF'
   _____            __ _                 _
  / ____|          / _| |               | |
 | |  __ _ __ __ _| |_| |_ ___ ___   __| | ___
 | | |_ | '__/ _` |  _| __/ __/ _ \ / _` |/ _ \
 | |__| | | | (_| | | | || (_| (_) | (_| |  __/
  \_____|_|  \__,_|_|  \__\___\___/ \__,_|\___|

EOF

  echo "Graftcode helps you generate AI code that integrates through Graftcode."
  echo "It can reduce boilerplate, simplify PRs, and save up to 80% of tokens."
  echo
  echo "This installer can:"
  echo "  1. Download Graftcode Rules file for your IDE"
  echo "     - so AI can generate code that integrates everything through Graftcode"
  echo "  2. Download Graftcode Gateway"
  echo "     - gateway for your processor"
  echo
}

read_choice() {
  local prompt="$1"
  shift
  local allowed=("$@")
  local choice

  while true; do
    read -r -p "$prompt" choice
    choice="$(echo "$choice" | xargs)"

    for allowed_choice in "${allowed[@]}"; do
      if [[ "$choice" == "$allowed_choice" ]]; then
        echo "$choice"
        return 0
      fi
    done

    echo "Invalid choice. Available options: ${allowed[*]}"
  done
}

need_command() {
  local cmd="$1"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
    exit 1
  fi
}

download_file() {
  local url="$1"
  local output="$2"
  local label="$3"

  echo "Downloading $label..."
  curl -fL --progress-bar "$url" -o "$output"
  echo "Downloaded $label"
}

install_rules() {
  echo
  echo "Choose IDE:"
  echo "  1. Cursor"
  echo

  local ide_choice
  ide_choice="$(read_choice "Enter choice [1]: " "1")"

  case "$ide_choice" in
    1)
      local rules_dir="$PWD/.cursor/rules"
      mkdir -p "$rules_dir"

      download_file "$RULE_DOTNET_URL" "$rules_dir/graftcode-dotnet.mdc" "graftcode-dotnet.mdc"
      download_file "$RULE_TS_URL" "$rules_dir/graftcode-typescript-node-nextjs.mdc" "graftcode-typescript-node-nextjs.mdc"

      echo
      echo "Installed Graftcode Cursor rules in:"
      echo "$rules_dir"
      ;;
  esac
}

detect_os_pattern() {
  local os_name
  os_name="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$os_name" in
    linux)
      echo "linux"
      ;;
    darwin)
      echo "darwin|macos|osx"
      ;;
    *)
      echo "Unsupported OS: $os_name" >&2
      exit 1
      ;;
  esac
}

detect_arch_pattern() {
  local arch_name
  arch_name="$(uname -m | tr '[:upper:]' '[:lower:]')"

  case "$arch_name" in
    arm64|aarch64)
      echo "arm64|aarch64"
      ;;
    x86_64|amd64)
      echo "x64|amd64|x86_64"
      ;;
    i386|i686|x86)
      echo "x86|i386|i686"
      ;;
    *)
      echo "Unsupported architecture: $arch_name" >&2
      exit 1
      ;;
  esac
}

extract_gateway() {
  local archive_path="$1"
  local extract_dir="$2"

  mkdir -p "$extract_dir"

  case "$archive_path" in
    *.zip)
      need_command unzip
      unzip -q "$archive_path" -d "$extract_dir"
      ;;
    *.tar.gz|*.tgz)
      tar -xzf "$archive_path" -C "$extract_dir"
      ;;
    *)
      echo "Unsupported archive format: $archive_path"
      exit 1
      ;;
  esac

  local found
  found="$(find "$extract_dir" -type f -name "$EXE_NAME" -perm -u+x -print -quit || true)"

  if [[ -z "$found" ]]; then
    found="$(find "$extract_dir" -type f -name "$EXE_NAME" -print -quit || true)"
  fi

  if [[ -z "$found" ]]; then
    echo "Could not find $EXE_NAME inside archive."
    echo "Extracted files:"
    find "$extract_dir" -maxdepth 4 -type f | sed 's/^/ - /'
    exit 1
  fi

  rm -f "$OUTPUT_PATH"
  cp "$found" "$OUTPUT_PATH"
  chmod +x "$OUTPUT_PATH"
}

install_gateway() {
  need_command curl
  need_command grep
  need_command sed
  need_command find

  local os_pattern
  local arch_pattern

  os_pattern="$(detect_os_pattern)"
  arch_pattern="$(detect_arch_pattern)"

  echo
  echo "Detected OS pattern: $os_pattern"
  echo "Detected architecture pattern: $arch_pattern"
  echo "Fetching latest release from $REPO..."

  local release_json
  release_json="$(mktemp)"

  curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" -o "$release_json"

  local asset_url
  asset_url="$(
    grep -oE '"browser_download_url": "[^"]+"' "$release_json" |
      sed -E 's/^"browser_download_url": "([^"]+)"/\1/' |
      grep -Ei '\.(zip|tar\.gz|tgz)$' |
      grep -Ei "($os_pattern)" |
      grep -Ei "($arch_pattern)" |
      grep -Eiv '(sha256|checksum|checksums|signature|sig)' |
      head -n 1
  )"

  if [[ -z "$asset_url" ]]; then
    echo "Could not find Gateway build for this machine."
    echo
    echo "Available downloadable assets:"
    grep -oE '"browser_download_url": "[^"]+"' "$release_json" |
      sed -E 's/^"browser_download_url": "([^"]+)"/ - \1/'
    rm -f "$release_json"
    exit 1
  fi

  local asset_name
  asset_name="$(basename "$asset_url")"

  local archive_path
  local extract_dir
  archive_path="$(mktemp -t "$asset_name.XXXXXX")"
  extract_dir="$(mktemp -d)"

  download_file "$asset_url" "$archive_path" "$asset_name"

  extract_gateway "$archive_path" "$extract_dir"

  rm -f "$archive_path" "$release_json"
  rm -rf "$extract_dir"

  echo
  echo "Installed Graftcode Gateway:"
  echo "$OUTPUT_PATH"
}

show_intro

echo "What do you want to install?"
echo "  1. Graftcode Rules file"
echo "  2. Graftcode Gateway"
echo

choice="$(read_choice "Enter choice [1/2]: " "1" "2")"

case "$choice" in
  1) install_rules ;;
  2) install_gateway ;;
esac

echo
echo "Done."
