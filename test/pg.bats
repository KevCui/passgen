#!/usr/bin/env bats
#
# How to run:
#   ~$ bats test/pg.bats

BATS_TEST_SKIPPED=

setup() {
    _SEPERATOR="-"
    _SCRIPT="./pg.sh"
    source $_SCRIPT
}

@test "CHECK: get_platform(): linux" {
    uname() {
        echo "Linux XXX"
    }
    run get_platform
    [ "$status" -eq 0 ]
    [ "$output" = "XXX" ]
}

@test "CHECK: get_platform(): macos" {
    uname() {
        echo "Darwin"
    }
    run get_platform
    [ "$status" -eq 0 ]
    [ "$output" = "macos" ]
}

@test "CHECK: get_platform(): OS not support" {
    uname() {
        echo "BlahBlah"
    }
    run get_platform
    [ "$status" -eq 1 ]
    [ "$output" = "OS not support!" ]
}

@test "CHECK: get_first_letter(): 1st letter at beginning" {
    run get_first_letter "a123bc"
    [ "$status" -eq 0 ]
    [ "$output" = "a" ]
}

@test "CHECK: get_first_letter(): 1st letter in middle" {
    run get_first_letter "12a34b56c"
    [ "$status" -eq 0 ]
    [ "$output" = "a" ]
}

@test "CHECK: get_first_letter(): no letter" {
    run get_first_letter "123456"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "CHECK: get_str_index(): not found" {
    run get_str_index "12a34b56c" "e"
    [ "$status" -eq 0 ]
    [ "$output" = "-1" ]
}

@test "CHECK: get_str_index(): found" {
    run get_str_index "12a34b56c" "b"
    [ "$status" -eq 0 ]
    [ "$output" = "5" ]
}

@test "CHECK: hash(): 1 char" {
    run hash "abcdefg" "1" false
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
}

@test "CHECK: hash(): 5 char" {
    run hash "abcdefg" "5" false
    [ "$status" -eq 0 ]
    [ "$output" = "1xakG" ]
}

@test "CHECK: hash(): 6 char" {
    run hash "abcdefg" "6" false
    [ "$status" -eq 0 ]
    [ "$output" = "1xakG-" ]
}

@test "CHECK: hash(): 105 max" {
    run hash "abcdefg" "105" false
    [ "$status" -eq 0 ]
    [ "$output" = "1xakG-IVpto-qxtt+-sF45X-ARTN8-Oo6HM-DjFIb-D5BJB-vGp2Q-k6MN6-sm8Jb-8he+Y-hsjLY-0GH9P-3f9kX-7CZ8f-9Uxrj-A==" ]
}

@test "CHECK: hash(): no letter for uppercase, 1 char" {
    _HEX_OUT=true
    run hash "aaaaaaaaa" "7" true
    [ "$status" -eq 0 ]
    [ "$output" = "A0729-4" ]
}

@test "CHECK: hash(): uppercase letter, index 0, 1 char" {
    run hash "f" "1" true
    [ "$status" -eq 0 ]
    [ "$output" = "C" ]
}

@test "CHECK: hash(): uppercase letter, index 0, 5 char" {
    run hash "f" "5" true
    [ "$status" -eq 0 ]
    [ "$output" = "CRwiR" ]
}

@test "CHECK: hash(): uppercase letter, index 1, 2 char" {
    run hash "aaa" "2" true
    [ "$status" -eq 0 ]
    [ "$output" = "1V" ]
}

@test "CHECK: hash(): uppercase letter, index 1, 20 char" {
    run hash "aaa" "20" true
    [ "$status" -eq 0 ]
    [ "$output" = "1VZEs-ZgS6X-tdhxZ-Y1" ]
}

@test "CHECK: hash(): hex, 6 char" {
    _HEX_OUT=true
    run hash "abcdefg" "6" false
    [ "$status" -eq 0 ]
    [ "$output" = "d716a-" ]
}

@test "CHECK: hash(): hex, uppercase letter, index 1, 20 char" {
    _HEX_OUT=true
    run hash "aaa" "20" true
    [ "$status" -eq 0 ]
    [ "$output" = "D6f64-4b198-12e97-b5" ]
}
