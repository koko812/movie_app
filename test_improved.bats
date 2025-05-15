#!/usr/bin/env bats

setup() {
  # 第1引数を環境変数にセット
  TEST_TARGET="$1"

  # ./がなければ付ける
  if [[ ! "$TEST_TARGET" =~ ^(\./|/|~) ]]; then
    TEST_TARGET="./$TEST_TARGET"
  fi

  # 実行ファイルの存在チェック
  if [ ! -f "$TEST_TARGET" ]; then
    echo "ERROR: Target file not found: $TEST_TARGET"
    exit 1
  fi

  # 実行権限チェック
  if [ ! -x "$TEST_TARGET" ]; then
    echo "ERROR: Target file is not executable: $TEST_TARGET"
    exit 1
  fi
}

TEST_TARGET=$TEST_TARGET

@test "Default args" {
  run "$TEST_TARGET"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Region: JP"* ]]
}

@test "Invalid option" {
  run "$TEST_TARGET" -x
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* || "$output" == *"Error"* ]]
}

@test "Start year > End year" {
  run "$TEST_TARGET" -s 2025 -e 2020
  [ "$status" -ne 0 ]
  [[ "$output" == *"Start year"* && "$output" == *"cannot be greater"* ]]
}

