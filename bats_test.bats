#!/usr/bin/env bats

setup() {
  # テスト対象スクリプトを1番目の引数で受け取る
  if [ -z "$TEST_TARGET" ]; then
    echo "ERROR: TEST_TARGET is not set"
    exit 1
  fi
}

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

