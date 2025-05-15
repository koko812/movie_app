#!/bin/bash

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color（リセット）

if [ $# -lt 1 ]; then
  echo "Usage: $0 path_to_script"
  exit 1
fi

TARGET="$1"
shift

# ./が先頭にない場合は自動で付けて報告
if [[ "$TARGET" != ./* ]]; then
  TARGET="./$TARGET"
  echo -e "${GREEN}Info:${NC} Added './' prefix to target script. New target: $TARGET"
fi

# 実行権限チェック・ユーザー確認付き付与
if [ ! -x "$TARGET" ]; then
  echo -e "${RED}Warning:${NC} File '$TARGET' is not executable."
  read -p "Do you want to add execute permission? (y/N): " ans
  case "$ans" in
    [Yy]* )
      chmod +x "$TARGET" || { echo -e "${RED}Failed to add execute permission.${NC}"; exit 1; }
      echo "Execute permission added."
      ;;
    * )
      echo "Cannot proceed without execute permission."
      exit 1
      ;;
  esac
fi

check_target_exists() {
  if [ -f "$TARGET" ]; then
    echo -e "${GREEN}Check:${NC} Target file exists: $TARGET"
    return 0
  else
    echo -e "${RED}Check:${NC} Target file NOT found: $TARGET"
    return 1
  fi
}

LOG_FILE="test_results.log"
run_test() {
  local test_name="$1"
  shift
  {
  echo "Running (expect success): $test_name"
  check_target_exists || { echo -e "${RED}FAIL:${NC} $test_name - Target file not found, skipping test"; echo; return 1; }

  output=$("$TARGET" "$@" 2>&1)
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}PASS:${NC} $test_name"
  else
    echo -e "${RED}FAIL:${NC} $test_name"
    echo "Exit code: $exit_code"
    echo "Output:"
    echo "$output"
    echo "----------------------------"
  fi
  echo
}| tee -a "$LOG_FILE" 
}

run_test_expect_failure() {
  local test_name="$1"
  shift

  echo "Running (expect failure): $test_name"
  check_target_exists || { echo -e "${RED}FAIL:${NC} $test_name - Target file not found, skipping test"; echo; return 1; }

  output=$("$TARGET" "$@" 2>&1)
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    echo -e "${GREEN}PASS:${NC} $test_name (error occurred as expected)"
  else
    echo -e "${RED}FAIL:${NC} $test_name (expected error but none occurred)"
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

