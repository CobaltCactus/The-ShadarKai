#!/bin/bash
# backup.bash: copy one or more BG3 mod folders and store them in a repo; if one mod then repo/<subdir>/..., else repo/<modname>/<subdir>/...
# derived by TheCobaltCactus from original code by mstephenson6, see guide at https://mod.io/g/baldursgate3/r/git-backups-for-mod-projects
set -e

#TODO: Set list of mod folder(s) here
MOD_SUBDIRS=(
  "ShadarKai_87c2216f-e6a3-1846-8be1-85f8988c0447"
  "ShadarKai_NoTatt_59370102-4347-cfd7-3ed5-4f6f66badb8a"
  "ShadarKai_Subrace_05f04f05-db8e-3390-1ed6-2861e65602bc"
  "ShadarKai_Subrace_NoTatt_46ae51b5-687d-b590-2408-07f6a2ba2a43"
)

#set this to your BG3/data folder path
BG3_DATA="/d/Program Files (x86)/Steam/steamapps/common/Baldurs Gate 3/Data"
# Look in "D:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3\Data\"
# for names of mods you have already started

SUBDIR_LIST=(
  "Projects"
  "Editor/Mods"
  "Mods"
  "Public"
  "Generated/Public"
)

if [ ${#MOD_SUBDIRS[@]} -eq 0 ]; then
  echo "MOD_SUBDIRS must contain at least one folder name in $(basename "$BASH_SOURCE")"
  exit 1
fi

single_mod=false
if [ ${#MOD_SUBDIRS[@]} -eq 1 ]; then
  single_mod=true
  single_name="${MOD_SUBDIRS[0]}"
fi

for modname in "${MOD_SUBDIRS[@]}"; do
  found_any=false

  for subdir in "${SUBDIR_LIST[@]}"; do
    src="$BG3_DATA/$subdir/$modname"

    if [ "$single_mod" = true ]; then
      dest="$subdir"                    # repo/<subdir>/...
    else
      dest="$modname/$subdir"           # repo/<modname>/<subdir>/...
    fi

    if [ -d "$src" ]; then
      found_any=true
      mkdir -p "$(dirname "$dest")"
      # remove existing destination to ensure sync
      rm -rf "$dest"
      cp -a "$src" "$dest"
    fi
  done

  if [ "$found_any" = false ]; then
    echo "Warning: mod '$modname' not found in any SUBDIR_LIST locations."
    if [ "$single_mod" = true ]; then
      rmdir --ignore-fail-on-non-empty "$single_name" 2>/dev/null || true
    else
      rmdir --ignore-fail-on-non-empty "$modname" 2>/dev/null || true
    fi
  fi
done

git add --all
git commit -m "Backup at $(date)"
git push
