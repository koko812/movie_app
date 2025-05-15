#!/bin/bash

# 保存先ディレクトリ名
POSTER_DIR="posters"

# 実行ディレクトリのフルパス
SCRIPT_DIR=$(pwd)

# 保存先ディレクトリの作成（存在しない場合だけ）
mkdir -p "$SCRIPT_DIR/$POSTER_DIR"

# ランダムページ・インデックス
PAGE=$((1 + RANDOM % 5))
INDEX=$((RANDOM % 20))

# APIからデータ取得
RESPONSE=$(curl -s "https://api.themoviedb.org/3/movie/popular?api_key=$TMDB_KEY&page=$PAGE")

# 情報を抽出
TITLE=$(echo "$RESPONSE" | jq -r ".results[$INDEX].title")
DATE=$(echo "$RESPONSE" | jq -r ".results[$INDEX].release_date")
OVERVIEW=$(echo "$RESPONSE" | jq -r ".results[$INDEX].overview")
POSTER_PATH=$(echo "$RESPONSE" | jq -r ".results[$INDEX].poster_path")

# ファイル名整形
FILENAME="${TITLE// /_}.jpg"
SAVE_PATH="$SCRIPT_DIR/$POSTER_DIR/$FILENAME"
POSTER_URL="https://image.tmdb.org/t/p/w500$POSTER_PATH"

# ポスター画像を保存（静かに）
wget -q -O "$SAVE_PATH" "$POSTER_URL"

# 情報表示
echo ""
echo "🎬 Title: $TITLE"
echo "📅 Release: $DATE"
echo "📝 Overview:"
echo "$OVERVIEW"
echo "🖼️  Poster saved to:"
echo "$SAVE_PATH"

