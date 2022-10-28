#!/usr/bin/env bash

# https://github.com/obsidianmd/obsidian-releases/blob/master/README.md
# https://docs.github.com/en/graphql/overview/explorer

# prerequisites (brew install jq fzf gh)
#   jq    https://stedolan.github.io/jq/
#   fzf   https://github.com/junegunn/fzf/
#   gh    https://cli.github.com/

feed='https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/community-plugins.json'
curlopts=( --location --silent --max-time 5 )
OUTDIR="$HOME/Downloads/obsidian-plugins"
FZF_HEADER='⌃ctrl+A=select all  ⌃ctrl+S=select none'
pfx='https://github.com'

# man gh-api
read -r -d '' GQL_QUERY <<-'EOQ'
query($name: String!, $owner: String!) {
  repository(owner: $owner, name: $name) {
    defaultBranchRef { name }
    releases(first: 10, orderBy: {field: CREATED_AT, direction: DESC}) {
      nodes { tagName, isDraft, isPrerelease }
    }
  }
}
EOQ

function _fetchVersion {
  local REPO_VER
  OWNER=${1%%/*}
  REPO=${1##*/}
  GQL_JSON=$(gh api graphql --field owner="$OWNER" --field name="$REPO" --raw-field query="$GQL_QUERY")
  if [ -n "$GQL_JSON" ] && [ "$GQL_JSON" != "null" ]; then
    REPO_VER=$(jq -r '.data.repository.releases.nodes |
      map(select(
        (.isDraft==false) and
        (.isPrerelease==false) and
        (.tagName|test("alpha|beta|rc";"i")|not)
      ))[0] |
      .tagName' <<<"$GQL_JSON" 2>/dev/null)
    case $REPO_VER in
      null|'') REPO_VER=$(jq -r '.data.repository.releases.nodes[0] | .tagName' <<<"$GQL_JSON" 2>/dev/null) ;;
    esac
    echo "$REPO_VER"
  fi
}

function _mkdir {
  mkdir -p "$OUTDIR" 2>/dev/null
  cd "$_" || exit 1
}

JSON=$(curl "${curlopts[@]}" -X GET $feed 2>/dev/null)
[ -n "$JSON" ] || exit 1
_mkdir

if command -v gh &>/dev/null; then
  use_graphql=true
  function _download {
    if gh repo clone "${1#$pfx/}" "$2" ${3:+-- --branch "$3"} &>/dev/null; then (( c++ )); fi;
  }
else
  if ! command -v git &>/dev/null; then
    echo 1>&2 "requires gh or git!"
    exit 1
  fi
  echo 1>&2 "% gh not present, falling back to git"
  function _download {
    if git clone ${3:+--branch "$3"} -- "$1" "$2" &>/dev/null; then (( c++ )); fi;
  }
fi

while IFS=$'\t' read -r URL _ ID ; do
  GH_USER_REPO=${URL#$pfx/}
  if [[ $use_graphql == true ]]; then
    unset CUR_VER LATEST_VER
    CUR_VER=$(jq -r '.version' "$ID/manifest.json" 2>/dev/null)
    LATEST_VER="$(_fetchVersion "$GH_USER_REPO")"
    if [[ "$LATEST_VER" == "$CUR_VER" ]]; then
      echo "$GH_USER_REPO: v${CUR_VER} already downloaded ✓"
      continue
    else
      rm -rf "${ID:?}"
    fi
  fi
  echo "$GH_USER_REPO: downloading${CUR_VER:+ v$CUR_VER →}${LATEST_VER:+ v$LATEST_VER}"
  if [[ -n "$ID" ]]; then
    _download "$URL" "$ID" "$LATEST_VER"
  fi
done < <(
  jq -r 'sort_by(.name) | .[] | [ .repo, .name, .description, .id ] | @tsv' <<<"$JSON" |
  tr -cd '[[:print:]]\n\t' |
  awk -v pfx=$pfx 'BEGIN { FS="\t" } { printf "%s/%s\t%s: %s\t%s\n",pfx,$1,$2,$3,$4 }' |
  sed $'s/\t/\u00a0\t/g' |
  column -s$'\t' -t |
  fzf -i ${1:+-q $1} --exact --multi --no-hscroll --no-mouse --no-select-1 \
      --delimiter $'\u00a0' \
      --with-nth 1,2 \
      --header="$FZF_HEADER" \
      --bind='ctrl-a:select-all,ctrl-s:deselect-all' \
      --preview-window='down,3,wrap' \
      --preview='echo {2}' |
  sed $'s/\u00a0\ */\t/g'
) |
awk -F: '{ printf "%-60s %s\n",$1,$2 }'
