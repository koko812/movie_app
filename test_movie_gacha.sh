#!/bin/bash

# テスト対象のスクリプト
TARGET="./movie_gacha.sh"

# テスト1: 正常動作（デフォルト引数）
echo "Test 1: Default args"
$TARGET > output.log 2>&1
if [ $? -eq 0 ]; then
  echo "PASS: script runs without error"
else
  echo "FAIL: script failed"
fi

# テスト2: 不正な引数でヘルプ表示されるか
echo "Test 2: Invalid option"
$TARGET -x > output.log 2>&1
grep -q "Usage:" output.log
if [ $? -eq 0 ]; then
  echo "PASS: help shown on invalid option"
else
  echo "FAIL: help NOT shown"
fi

# テスト3: 開始年 > 終了年のエラー判定
echo "Test 3: Start year > End year"
$TARGET -s 2025 -e 2020 > output.log 2>&1
grep -q "Error:" output.log
if [ $? -eq 0 ]; then
  echo "PASS: error shown for invalid year range"
else
  echo "FAIL: error NOT shown"
fi

