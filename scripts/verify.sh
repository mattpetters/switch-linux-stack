#!/usr/bin/env bash
# Check every row of stack.lock.tsv: commit reachable in our copy, and index gitlink matches.
cd "$(dirname "$0")/.." || exit 1
gh_auth=(-c 'credential.helper=!gh auth git-credential')
fail=0
while IFS=$'\t' read -r path url _ branch sha _; do
  tip=$(git "${gh_auth[@]}" ls-remote "$url" "refs/heads/$branch" | cut -f1)
  if [ "$tip" = "$sha" ]; then :; elif gh api "repos/${url#https://github.com/}/commits/$sha" -q .sha >/dev/null 2>&1; then
    echo "NOTE $path: branch moved to ${tip:-none}, pinned commit still reachable"
  else echo "FAIL $path: pinned commit $sha not found in $url"; fail=1; continue; fi
  idx=$(git ls-files -s -- "$path" | awk '{print $2}')
  [ "$idx" = "$sha" ] || { echo "FAIL $path: index has ${idx:-nothing}, lock has $sha"; fail=1; continue; }
  echo "ok   $path $sha"
done < <(tail -n +2 stack.lock.tsv)
exit $fail
