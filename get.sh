#!/bin/sh
set -eu

REPO="grft-dev/graftcode-gateway"
EXE_NAME="gg"
OUTPUT_PATH="$PWD/$EXE_NAME"

RULE_DOTNET_URL="https://raw.githubusercontent.com/grft-dev/graftcode-demos/refs/heads/main/rules/Cursor/.cursor/rules/graftcode-dotnet.mdc"
RULE_TS_URL="https://raw.githubusercontent.com/grft-dev/graftcode-demos/refs/heads/main/rules/Cursor/.cursor/rules/graftcode-typescript-node-nextjs.mdc"

show_intro() {
  clear 2>/dev/null || true

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

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

download_file() {
  url="$1"
  output="$2"
  label="$3"

  echo "Downloading $label..."

  if has_cmd curl; then
    curl -fL "$url" -o "$output"
  elif has_cmd wget; then
    wget -O "$output" "$url"
  elif has_cmd busybox; then
    busybox wget -O "$output" "$url"
  else
    echo "Error: curl, wget or busybox wget is required to download files."
    exit 1
  fi

  echo "Downloaded $label"
}

read_choice_12() {
  while :; do
    printf "Enter choice [1/2]: "
    read choice

    case "$choice" in
      1|2)
        echo "$choice"
        return
        ;;
      *)
        echo "Invalid choice. Available options: 1, 2"
        ;;
    esac
  done
}

read_choice_cursor() {
  while :; do
    printf "Enter choice [1]: "
    read choice

    case "$choice" in
      1)
        echo "$choice"
        return
        ;;
      *)
        echo "Invalid choice. Available options: 1"
        ;;
    esac
  done
}

install_rules() {
  echo
  echo "Choose IDE:"
  echo "  1. Cursor"
  echo

  ide_choice="$(read_choice_cursor)"

  case "$ide_choice" in
    1)
      rules_dir="$PWD/.cursor/rules"
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
  os_name="$(uname -s | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz')"

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
  arch_name="$(uname -m | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz')"

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
  archive_path="$1"
  extract_dir="$2"

  mkdir -p "$extract_dir"

  case "$archive_path" in
    *.zip)
      if has_cmd unzip; then
        unzip -q "$archive_path" -d "$extract_dir"
      else
        echo "Error: unzip is required to extract .zip files."
        exit 1
      fi
      ;;
    *.tar.gz|*.tgz)
      tar -xzf "$archive_path" -C "$extract_dir"
      ;;
    *)
      echo "Unsupported archive format: $archive_path"
      exit 1
      ;;
  esac

  found="$(find "$extract_dir" -type f -name "$EXE_NAME" -print | head -n 1 || true)"

  if [ -z "$found" ]; then
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
  os_pattern="$(detect_os_pattern)"
  arch_pattern="$(detect_arch_pattern)"

  echo
  echo "Detected OS pattern: $os_pattern"
  echo "Detected architecture pattern: $arch_pattern"
  echo "Fetching latest release from $REPO..."

  release_json="$(mktemp)"
  download_file "https://api.github.com/repos/$REPO/releases/latest" "$release_json" "latest release metadata"

  asset_url="$(
    grep '"browser_download_url"' "$release_json" |
      sed 's/.*"browser_download_url": "\(.*\)".*/\1/' |
      grep -Ei '\.(zip|tar\.gz|tgz)$' |
      grep -Ei "$os_pattern" |
      grep -Ei "$arch_pattern" |
      grep -Eiv '(sha256|checksum|checksums|signature|sig)' |
      head -n 1 || true
  )"

  if [ -z "$asset_url" ]; then
    echo "Could not find Gateway build for this machine."
    echo
    echo "Available downloadable assets:"
    grep '"browser_download_url"' "$release_json" |
      sed 's/.*"browser_download_url": "\(.*\)".*/ - \1/'
    rm -f "$release_json"
    exit 1
  fi

  asset_name="$(basename "$asset_url")"

  tmp_dir="$(mktemp -d)"
  archive_path="$tmp_dir/$asset_name"
  extract_dir="$tmp_dir/extract"

  download_file "$asset_url" "$archive_path" "$asset_name"
  extract_gateway "$archive_path" "$extract_dir"

  rm -rf "$tmp_dir"
  rm -f "$release_json"

  echo
  echo "Installed Graftcode Gateway:"
  echo "$OUTPUT_PATH"
}

show_intro

echo "What do you want to install?"
echo "  1. Graftcode Rules file"
echo "  2. Graftcode Gateway"
echo

choice="$(read_choice_12)"

case "$choice" in
  1) install_rules ;;
  2) install_gateway ;;
esac

echo
echo "Done."
