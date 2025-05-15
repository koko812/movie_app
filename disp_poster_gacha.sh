#!/bin/bash

# ランダムページ・インデックス
PAGE=$((1 + RANDOM % 5))
INDEX=$((RANDOM % 20))

# データ取得
RESPONSE=$(curl -s "https://api.themoviedb.org/3/movie/popular?api_key=$TMDB_KEY&page=$PAGE")

# 情報抽出
TITLE=$(echo "$RESPONSE" | jq -r ".results[$INDEX].title")
DATE=$(echo "$RESPONSE" | jq -r ".results[$INDEX].release_date")
OVERVIEW=$(echo "$RESPONSE" | jq -r ".results[$INDEX].overview")
POSTER_PATH=$(echo "$RESPONSE" | jq -r ".results[$INDEX].poster_path")

# ファイル名（スペースをアンダースコアに）
FILENAME="${TITLE// /_}.jpg"
POSTER_URL="https://image.tmdb.org/t/p/w500$POSTER_PATH"

# 保存＆表示
wget -q -O "$FILENAME" "$POSTER_URL" && open "$FILENAME"

# ターミナルに表示
echo ""
echo "🎬 Title: $TITLE"
echo "📅 Release: $DATE"
echo "📝 Overview:"
echo "$OVERVIEW"
echo "🖼️  Saved poster as: $FILENAME"

