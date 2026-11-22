#!/usr/bin/env bash
# Bring forks up to date with upstream, then rewrite pins. --dry-run only reports.
cd "$(dirname "$0")/.." || exit 1
dry=0; [ "$1" = "--dry-run" ] && dry=1
gh_auth=(-c 'credential.helper=!gh auth git-credential')
tip() { git "${gh_auth[@]}" ls-remote "$1" "refs/heads/$2" | cut -f1; }
out=stack.lock.tsv.new; head -1 stack.lock.tsv > "$out"
while IFS=$'\t' read -r path url up branch sha why; do
  repo=${url#https://github.com/}; new=$sha
  if [[ $up == https://github.com/* ]]; then
    if [ $dry = 1 ]; then
      new=$(tip "$up" "$branch"); new=${new:-$sha}
      echo "would run: gh repo sync $repo --branch $branch   (upstream tip $new)"
    else gh repo sync "$repo" --branch "$branch" >&2 && new=$(tip "$url" "$branch"); fi
  else
    echo "manual (GitLab mirror, $path): git clone --bare $up m.git && git -C m.git push --force $url $branch" >&2
    [ $dry = 1 ] && { new=$(tip "$up" "$branch"); new=${new:-$sha}; } || new=$(tip "$url" "$branch")
  fi
  if [ "$new" != "$sha" ]; then
    echo "pin change $path: $sha -> $new"
    [ $dry = 1 ] || git update-index --cacheinfo 160000,"$new","$path"
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$path" "$url" "$up" "$branch" "$new" "$why" >> "$out"
done < <(tail -n +2 stack.lock.tsv)
if [ $dry = 1 ]; then rm "$out"; else mv "$out" stack.lock.tsv; fi
