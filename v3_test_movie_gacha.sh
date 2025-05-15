#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 path_to_script"
  exit 1
fi

TARGET="$1"
shift

# ファイル存在チェック
if [ ! -f "$TARGET" ]; then
  echo "Error: File not found: $TARGET"
  exit 1
fi

# 権限チェック（なければユーザーに許可を求めて付与）
if [ ! -x "$TARGET" ]; then
  echo "Warning: File '$TARGET' is not executable."
  read -p "Do you want to add execute permission? (y/N): " ans
  case "$ans" in
    [Yy]* )
      chmod +x "$TARGET" || { echo "Failed to add execute permission."; exit 1; }
      echo "Execute permission added."
      ;;
    * )
      echo "Cannot proceed without execute permission."
      exit 1
      ;;
  esac
fi


run_test() {
  local test_name="$1"
  shift
  echo "Running (expect success): $test_name"

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

run_test_expect_failure() {
  local test_name="$1"
  shift
  echo "Running (expect failure): $test_name"

  output=$("$TARGET" "$@" 2>&1)
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    echo "PASS: $test_name (error occurred as expected)"
  else
    echo "FAIL: $test_name (expected error but none occurred)"
    echo "Output:"
    echo "$output"
    echo "----------------------------"
  fi
  echo
}

# 正常系テスト例
run_test "Default args"

# 異常系テスト例
run_test_expect_failure "Invalid option" -x
run_test_expect_failure "Start year > End year" -s 2025 -e 2020

