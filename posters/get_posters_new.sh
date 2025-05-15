#!/bin/bash

POSTER_BASE_DIR="posters"
SCRIPT_DIR=$(pwd)
mkdir -p "$SCRIPT_DIR/$POSTER_BASE_DIR"

GENRE_JSON=$(curl -s "https://api.themoviedb.org/3/genre/movie/list?api_key=$TMDB_KEY&language=ja-JP")

get_genre_names() {
  local ids=($1)
  local names=()
  for id in "${ids[@]}"; do
    name=$(echo "$GENRE_JSON" | jq -r ".genres[] | select(.id==$id) | .name")
    names+=("$name")
  done
  echo "${names[*]}" | sed 's/ /, /g'
}

PAGE=1
RESPONSE=$(curl -s "https://api.themoviedb.org/3/movie/popular?api_key=$TMDB_KEY&region=JP&page=$PAGE")

for INDEX in {0..4}; do
  TITLE=$(echo "$RESPONSE" | jq -r ".results[$INDEX].title")
  DATE=$(echo "$RESPONSE" | jq -r ".results[$INDEX].release_date")
  OVERVIEW=$(echo "$RESPONSE" | jq -r ".results[$INDEX].overview")
  POSTER_PATH=$(echo "$RESPONSE" | jq -r ".results[$INDEX].poster_path")
  GENRE_IDS=$(echo "$RESPONSE" | jq -r ".results[$INDEX].genre_ids | join(\" \")")
  GENRE_NAMES=$(get_genre_names "$GENRE_IDS")

  # メインジャンルでフォルダ作成（複数ジャンルの場合は最初のジャンルを使う）
  MAIN_GENRE=$(echo "$GENRE_NAMES" | cut -d',' -f1 | xargs) # カンマ区切りの最初のジャンル名を取得してtrim

  DIR_PATH="$SCRIPT_DIR/$POSTER_BASE_DIR/$MAIN_GENRE"
  mkdir -p "$DIR_PATH"

  # ファイル名作成（スペースをアンダースコアに）
  SAFE_TITLE="${TITLE// /_}"
  POSTER_SAVE_PATH="$DIR_PATH/${SAFE_TITLE}.jpg"
  METADATA_SAVE_PATH="$DIR_PATH/${SAFE_TITLE}.json"
  POSTER_URL="https://image.tmdb.org/t/p/w500$POSTER_PATH"

  wget -q -O "$POSTER_SAVE_PATH" "$POSTER_URL"

  # メタデータJSONを作成
  cat > "$METADATA_SAVE_PATH" << EOF
{
  "title": "$TITLE",
  "release_date": "$DATE",
  "overview": "$OVERVIEW",
  "genres": "$GENRE_NAMES",
  "poster_path": "$POSTER_SAVE_PATH"
}
EOF

  echo ""
  echo "🎬 Title: $TITLE"
  echo "📅 Release: $DATE"
  echo "🎭 Genres: $GENRE_NAMES"
  echo "🖼️  Poster saved to: $POSTER_SAVE_PATH"
  echo "🗂️  Metadata saved to: $METADATA_SAVE_PATH"
done

