#!/bin/bash

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color（リセット）

LOG_FILE="test_results.log"

if [ $# -lt 1 ]; then
  echo "Usage: $0 path_to_script"
  exit 1
fi

TARGET="$1"
shift

if [[ "$TARGET" != ./* ]]; then
  TARGET="./$TARGET"
  echo -e "${GREEN}Info:${NC} Added './' prefix to target script. New target: $TARGET" | tee -a "$LOG_FILE"
fi

if [ ! -f "$TARGET" ]; then
  echo -e "${RED}Error:${NC} File not found: $TARGET" | tee -a "$LOG_FILE"
  exit 1
fi

if [ ! -x "$TARGET" ]; then
  echo -e "${RED}Warning:${NC} File '$TARGET' is not executable." | tee -a "$LOG_FILE"
  read -p "Do you want to add execute permission? (y/N): " ans
  case "$ans" in
    [Yy]* )
      chmod +x "$TARGET" || { echo -e "${RED}Failed to add execute permission.${NC}" | tee -a "$LOG_FILE"; exit 1; }
      echo "Execute permission added." | tee -a "$LOG_FILE"
      ;;
    * )
      echo "Cannot proceed without execute permission." | tee -a "$LOG_FILE"
      exit 1
      ;;
  esac
fi

# 日時ログ
echo "=== Test run started at $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$LOG_FILE"

total_tests=0
passed_tests=0

check_target_exists() {
  if [ -f "$TARGET" ]; then
    echo -e "${GREEN}Check:${NC} Target file exists: $TARGET" | tee -a "$LOG_FILE"
    return 0
  else
    echo -e "${RED}Check:${NC} Target file NOT found: $TARGET" | tee -a "$LOG_FILE"
    return 1
  fi
}

run_test() {
  local test_name="$1"
  shift
  ((total_tests++))

  echo "Running (expect success): $test_name" | tee -a "$LOG_FILE"
  check_target_exists || { echo -e "${RED}FAIL:${NC} $test_name - Target file not found, skipping test" | tee -a "$LOG_FILE"; echo; return 1; }

  output=$("$TARGET" "$@" 2>&1)
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}PASS:${NC} $test_name" | tee -a "$LOG_FILE"
    ((passed_tests++))
  else
    echo -e "${RED}FAIL:${NC} $test_name" | tee -a "$LOG_FILE"
    echo "Exit code: $exit_code" | tee -a "$LOG_FILE"
    echo "Output:" | tee -a "$LOG_FILE"
    echo "$output" | tee -a "$LOG_FILE"
    echo "----------------------------" | tee -a "$LOG_FILE"
  fi
  echo | tee -a "$LOG_FILE"
}

run_test_expect_failure() {
  local test_name="$1"
  shift
  ((total_tests++))

  echo "Running (expect failure): $test_name" | tee -a "$LOG_FILE"
  check_target_exists || { echo -e "${RED}FAIL:${NC} $test_name - Target file not found, skipping test" | tee -a "$LOG_FILE"; echo; return 1; }

  output=$("$TARGET" "$@" 2>&1)
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    echo -e "${GREEN}PASS:${NC} $test_name (error occurred as expected)" | tee -a "$LOG_FILE"
    ((passed_tests++))
  else
    echo -e "${RED}FAIL:${NC} $test_name (expected error but none occurred)" | tee -a "$LOG_FILE"
    echo "Output:" | tee -a "$LOG_FILE"
    echo "$output" | tee -a "$LOG_FILE"
    echo "----------------------------" | tee -a "$LOG_FILE"
  fi
  echo | tee -a "$LOG_FILE"
}

# ここからテストケース
run_test "Default args"
run_test_expect_failure "Invalid option" -x
run_test_expect_failure "Start year > End year" -s 2025 -e 2020

# サマリ表示
echo "=== Test run ended at $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$LOG_FILE"
echo "Total tests: $total_tests" | tee -a "$LOG_FILE"
echo -e "${GREEN}Passed tests: $passed_tests${NC}" | tee -a "$LOG_FILE"
echo -e "${RED}Failed tests: $((total_tests - passed_tests))${NC}" | tee -a "$LOG_FILE"

