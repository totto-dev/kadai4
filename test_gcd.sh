#!/bin/bash

# =================================================================
# test_gcd.sh
# 概要：gcd.sh に対してさまざまな入力を行い、想定通りの挙動を
#       しているか自動でチェックするテストスクリプト。
#       1つでも想定と異なる結果があればエラー終了(exit 1)する。
#       全テスト成功なら正常終了(exit 0)する。
#       GitHub Actions はこの終了ステータスで成否を判定する。
# 使い方：./test_gcd.sh
# 作成者：伏見 知子 (26745130)
# =================================================================

# テスト対象スクリプト
GCD="./gcd.sh"

# テスト件数と失敗件数のカウンタ
total=0
failed=0

# -----------------------------------------------------------------
# assert_success: 正常系テスト用
#   引数1,2 を gcd.sh に渡し、出力が期待値と一致するか確認する。
#   $1=入力a  $2=入力b  $3=期待する出力(最大公約数)
# -----------------------------------------------------------------
assert_success() {
    local a="$1"
    local b="$2"
    local expected="$3"
    total=$((total + 1))

    # gcd.sh を実行し、標準出力と終了ステータスを取得
    local actual
    actual=$("$GCD" "$a" "$b" 2>/dev/null)
    local status=$?

    # 正常終了(0)かつ 出力が期待値と一致 すれば成功
    if [ "$status" -eq 0 ] && [ "$actual" = "$expected" ]; then
        echo "[OK]   gcd($a, $b) = $actual  (期待値: $expected)"
    else
        echo "[FAIL] gcd($a, $b) → 出力:'$actual' 終了状態:$status  (期待値: $expected / 終了状態0)"
        failed=$((failed + 1))
    fi
}

# -----------------------------------------------------------------
# assert_error: 異常系テスト用
#   不正な入力を渡し、gcd.sh がエラー終了(終了ステータス != 0)
#   するかどうかを確認する。
#   引数：gcd.sh に渡す引数列（個数は可変）
# -----------------------------------------------------------------
assert_error() {
    total=$((total + 1))

    # 不正入力で実行。出力は捨て、終了ステータスだけ見る
    "$GCD" "$@" >/dev/null 2>&1
    local status=$?

    # 終了ステータスが0以外（=エラー終了）なら成功
    if [ "$status" -ne 0 ]; then
        echo "[OK]   不正入力 [$*] → エラー終了 (終了状態:$status)"
    else
        echo "[FAIL] 不正入力 [$*] → 正常終了してしまった (エラー終了すべき)"
        failed=$((failed + 1))
    fi
}

echo "=================================================="
echo " gcd.sh テスト開始"
echo "=================================================="

# ===== 正常系テスト =====
echo ""
echo "----- 正常系（正しい最大公約数を返すか） -----"
assert_success 2 4 2          # 課題例：2と4 → 2
assert_success 12 18 6        # 一般的なケース
assert_success 18 12 6        # 引数の順序を入れ替えても同じ
assert_success 17 5 1         # 互いに素 → 1
assert_success 100 75 25      # 2桁・3桁
assert_success 7 7 7          # 同じ数 → その数自身
assert_success 1 1 1          # 最小の自然数
assert_success 1 9999 1       # 1との最大公約数は必ず1
assert_success 1071 1029 21   # 大きめの数（互除法が複数回回る）
assert_success 1000000 999999 1            # 大きな数
assert_success 123456789 987654321 9       # 極度に大きい数

# ===== 異常系テスト =====
echo ""
echo "----- 異常系（エラー終了すべき入力） -----"
assert_error 3                # 引数が少ない（1個）
assert_error 1 2 3            # 引数が多い（3個）
assert_error                  # 引数なし（0個）
assert_error -5 10            # 負の数
assert_error 10 -5            # 負の数（2番目）
assert_error 3.5 2            # 小数
assert_error 2 3.5            # 小数（2番目）
assert_error abc 5            # 文字列
assert_error 5 xyz            # 文字列（2番目）
assert_error 0 5             # 0（自然数でない）
assert_error 5 0             # 0（2番目）
assert_error "" 5            # 空文字
assert_error "1 2" 3        # 引数内にスペース（不正）

# ===== 結果集計 =====
echo ""
echo "=================================================="
echo " テスト結果: 全 $total 件中 $((total - failed)) 件成功 / $failed 件失敗"
echo "=================================================="

# 1件でも失敗があればエラー終了。GitHub Actions が失敗を検知できる。
if [ "$failed" -ne 0 ]; then
    echo "[RESULT] テスト失敗。gcd.sh の挙動が想定と異なります。" >&2
    exit 1
fi

echo "[RESULT] 全テスト成功。"
exit 0
