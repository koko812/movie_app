#!/bin/bash

usage() {
  echo "Usage: $0 [-r region] [-s start_year] [-e end_year]"
  echo "  -r region      : JP, US, etc. Default: JP"
  echo "  -s start_year  : e.g. 2010. Default: 2020"
  echo "  -e end_year    : e.g. 2020. Default: 2020"
  echo ""
  echo "Example:"
  echo "  $0 -r JP -s 2015 -e 2020"
  echo "  $0 -r US -s 2000 -e 2005"
  exit 1
}

# デフォルト値
REGION="JP"
START_YEAR="2020"
END_YEAR="2020"

# オプション解析
while getopts "r:s:e:h" opt; do
  case $opt in
    r) REGION=$OPTARG ;;
    s) START_YEAR=$OPTARG ;;
    e) END_YEAR=$OPTARG ;;
    h) usage ;;
    *) usage ;;
  esac
done

echo "Region: $REGION"
echo "Start Year: $START_YEAR"
echo "End Year: $END_YEAR"

POSTER_BASE_DIR="posters"
SCRIPT_DIR=$(pwd)
mkdir -p "$SCRIPT_DIR/$POSTER_BASE_DIR"

echo "Region: $REGION"
echo "Start Year: $START_YEAR"
echo "End Year: $END_YEAR"

HISTORY_FILE="$SCRIPT_DIR/query_history.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') REGION=$REGION START_YEAR=$START_YEAR END_YEAR=$END_YEAR" >> "$HISTORY_FILE"

POSTER_BASE_DIR="posters"
SCRIPT_DIR=$(pwd)
mkdir -p "$SCRIPT_DIR/$POSTER_BASE_DIR"


# 英語版ジャンル一覧を取得
GENRE_JSON=$(curl -s "https://api.themoviedb.org/3/genre/movie/list?api_key=$TMDB_KEY&language=en-US")

get_genre_names() {
  local ids=($1)
  local names=()
  for id in "${ids[@]}"; do
    name=$(echo "$GENRE_JSON" | jq -r ".genres[] | select(.id==$id) | .name")
    names+=("$name")
  done
  echo "${names[*]}" | sed 's/ /, /g'
}

API_URL="https://api.themoviedb.org/3/discover/movie?api_key=$TMDB_KEY&region=$REGION&primary_release_date.gte=${START_YEAR}-01-01&primary_release_date.lte=${END_YEAR}-12-31&page=1"

RESPONSE=$(curl -s "$API_URL")

for INDEX in {0..4}; do
  TITLE=$(echo "$RESPONSE" | jq -r ".results[$INDEX].title")
  DATE=$(echo "$RESPONSE" | jq -r ".results[$INDEX].release_date")
  OVERVIEW=$(echo "$RESPONSE" | jq -r ".results[$INDEX].overview")
  POSTER_PATH=$(echo "$RESPONSE" | jq -r ".results[$INDEX].poster_path")
  GENRE_IDS=$(echo "$RESPONSE" | jq -r ".results[$INDEX].genre_ids | join(\" \")")
  GENRE_NAMES=$(get_genre_names "$GENRE_IDS")
  RATING=$(echo "$RESPONSE" | jq -r ".results[$INDEX].vote_average")

  MAIN_GENRE=$(echo "$GENRE_NAMES" | cut -d',' -f1 | xargs)
  SAFE_MAIN_GENRE=${MAIN_GENRE// /_}

  DIR_PATH="$SCRIPT_DIR/$POSTER_BASE_DIR/$SAFE_MAIN_GENRE"
  mkdir -p "$DIR_PATH"

  SAFE_TITLE="${TITLE// /_}"
  POSTER_SAVE_PATH="$DIR_PATH/${SAFE_TITLE}.jpg"
  POSTER_REL_PATH="${POSTER_BASE_DIR}/${SAFE_MAIN_GENRE}/${SAFE_TITLE}.jpg"
  METADATA_SAVE_PATH="$DIR_PATH/${SAFE_TITLE}.json"
  POSTER_URL="https://image.tmdb.org/t/p/w500$POSTER_PATH"

  wget -q -O "$POSTER_SAVE_PATH" "$POSTER_URL"

  cat > "$METADATA_SAVE_PATH" << EOF
{
  "title": "$TITLE",
  "release_date": "$DATE",
  "overview": "$OVERVIEW",
  "genres": "$GENRE_NAMES",
  "rating": $RATING,
  "poster_path": "$POSTER_REL_PATH"
}
EOF

  echo ""
  echo "🎬 Title: $TITLE"
  echo "📅 Release: $DATE"
  echo "⭐️ Rating: $RATING / 10"
  echo "🎭 Genres: $GENRE_NAMES"
  echo "📝 Overview:"
  echo "$OVERVIEW"
  echo "🖼️  Poster saved to: $POSTER_SAVE_PATH"
  echo "🗂️  Metadata saved to: $METADATA_SAVE_PATH"
done

