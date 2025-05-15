#!/bin/bash

PAGE=$((1 + RANDOM % 5))  # 1〜5ページからランダムに選ぶ
INDEX=$((RANDOM % 20))    # その中の20件からランダムに選ぶ

POSTER_PATH=$(curl -s "https://api.themoviedb.org/3/movie/popular?api_key=$TMDB_KEY&page=$PAGE" | jq -r ".results[$INDEX].poster_path")

POSTER_URL="https://image.tmdb.org/t/p/w500$POSTER_PATH"

wget -O poster.jpg "$POSTER_URL" && open poster.jpg

