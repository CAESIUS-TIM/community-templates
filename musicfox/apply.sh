#!/usr/bin/env bash
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/go-musicfox"
config_file="$config_dir/config.toml"
theme_name="Noctalia"

# Nothing to patch until musicfox has written its config (run musicfox once).
# The theme file is still rendered; it activates on the next theme change.
[ -f "$config_file" ] || exit 0

# Idempotent: already selected.
if grep -Eq '^\s*activeTheme\s*=\s*"Noctalia"\s*$' "$config_file"; then
    exit 0
fi

# 1) An activeTheme line exists (anywhere, once): replace its value only.
if grep -Eq '^\s*activeTheme\s*=' "$config_file"; then
    sed -i -E '0,/^\s*activeTheme\s*=.*$/s//activeTheme = "Noctalia"/' "$config_file"
    exit 0
fi

# 2) No activeTheme key, but a [theme] section: insert the key right after it.
if grep -q '^\s*\[theme\]' "$config_file"; then
    awk -v line="activeTheme = \"$theme_name\"" '
        /^\s*\[theme\]/ && !done { print; print line; done = 1; next }
        { print }
    ' "$config_file" > "$config_file.tmp"
    mv "$config_file.tmp" "$config_file"
    exit 0
fi

# 3) No [theme] section at all: append a minimal one.
printf '\n[theme]\nactiveTheme = "%s"\n' "$theme_name" >> "$config_file"