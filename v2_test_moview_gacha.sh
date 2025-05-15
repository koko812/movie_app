#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 path_to_script [args...]"
  exit 1
fi

TARGET="$1"
shift

if [[ "$TARGET" != ./* ]]; then
  TARGET="./$TARGET"
fi

if [ ! -f "$TARGET" ]; then
  echo "Error: File not found: $TARGET"
  exit 1
fi

if [ ! -x "$TARGET" ]; then
  echo "Warning: File is not executable. Trying to add execute permission."
  chmod +x "$TARGET" || { echo "Failed to add execute permission."; exit 1; }
fi


run_test() {
  local test_name="$1"
  shift
  echo "Running: $test_name"

  output=$("$TARGET" "$@" 2>&1)
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    echo "PASS: $test_name"
  else
    echo "FAIL: $test_name"
    echo "Exit code: $exit_code"
    echo "Output:"
    echo "$output"
    echo "----------------------------"
  fi
  echo
}

# 例：TARGET に渡したスクリプトを色んなパターンでテスト

# デフォルト引数でのテスト（引数なし）
run_test "Default args"

# 存在しないオプションでヘルプ表示テスト
run_test "Invalid option" -x

# 開始年 > 終了年のエラー判定テスト
run_test "Start year > End year" -s 2025 -e 2020

