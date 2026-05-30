#!/bin/sh

# =================================================================
# test_gcd.sh
# 概要：gcd.sh にさまざまな入力を行い、想定どおりの挙動をするか検証する。
#       想定と異なる場合は ERROR_EXIT でエラーメッセージを表示し、
#       終了ステータス1で異常終了する。全テスト成功なら正常終了する。
#       GitHub Actions はこの終了ステータスで成否を判定する。
# 使い方：./test_gcd.sh
# 作成者：伏見 知子 (26745130)
# =================================================================

tmp=/tmp/$$                              # 変数を使って表記を短く

# 期待する出力の準備
echo "input 2 argments"   > $tmp-args    # 回答準備：引数の数エラー
echo "input natural number" > $tmp-nat   # 回答準備：数字じゃないエラー

# エラー終了用の関数
ERROR_EXIT () {
    echo "$1" 1>&2                       # エラーメッセージ(引数1)を標準エラー出力に表示
    rm -f $tmp-*                         # 作ったファイルの削除
    exit 1                               # エラー終了
}

# =====================================================
# テスト開始
# =====================================================

# --- test1: 引数の数が足りない ---
./gcd.sh 2 > $tmp-ans 2>&1 && ERROR_EXIT "error in test1-1"  # 異常終了すべき(成功したらエラー)
diff $tmp-ans $tmp-args > /dev/null || ERROR_EXIT "error in test1-2"  # 出力が期待通りか

# --- test2: 引数が多い ---
./gcd.sh 1 2 3 > $tmp-ans 2>&1 && ERROR_EXIT "error in test2-1"
diff $tmp-ans $tmp-args > /dev/null || ERROR_EXIT "error in test2-2"

# --- test3: 数値でない（文字列） ---
./gcd.sh abc 5 > $tmp-ans 2>&1 && ERROR_EXIT "error in test3-1"
diff $tmp-ans $tmp-nat > /dev/null || ERROR_EXIT "error in test3-2"

# --- test4: 小数 ---
./gcd.sh 3.5 2 > $tmp-ans 2>&1 && ERROR_EXIT "error in test4-1"
diff $tmp-ans $tmp-nat > /dev/null || ERROR_EXIT "error in test4-2"

# --- test5: 負の数 ---
./gcd.sh -5 10 > $tmp-ans 2>&1 && ERROR_EXIT "error in test5-1"
diff $tmp-ans $tmp-nat > /dev/null || ERROR_EXIT "error in test5-2"

# --- test6: 0（自然数でない） ---
./gcd.sh 0 5 > $tmp-ans 2>&1 && ERROR_EXIT "error in test6-1"
diff $tmp-ans $tmp-nat > /dev/null || ERROR_EXIT "error in test6-2"

# --- test7: 正常系 gcd(12,18)=6 ---
echo "6" > $tmp-exp
./gcd.sh 12 18 > $tmp-ans 2>&1 || ERROR_EXIT "error in test7-1"  # 正常終了すべき
diff $tmp-ans $tmp-exp > /dev/null || ERROR_EXIT "error in test7-2"

# --- test8: 正常系 gcd(2,4)=2 ---
echo "2" > $tmp-exp
./gcd.sh 2 4 > $tmp-ans 2>&1 || ERROR_EXIT "error in test8-1"
diff $tmp-ans $tmp-exp > /dev/null || ERROR_EXIT "error in test8-2"

# --- test9: 正常系 gcd(17,5)=1（互いに素） ---
echo "1" > $tmp-exp
./gcd.sh 17 5 > $tmp-ans 2>&1 || ERROR_EXIT "error in test9-1"
diff $tmp-ans $tmp-exp > /dev/null || ERROR_EXIT "error in test9-2"

# --- test10: 正常系 gcd(100,75)=25 ---
echo "25" > $tmp-exp
./gcd.sh 100 75 > $tmp-ans 2>&1 || ERROR_EXIT "error in test10-1"
diff $tmp-ans $tmp-exp > /dev/null || ERROR_EXIT "error in test10-2"

# --- test11: 正常系 大きな数 gcd(1071,1029)=21 ---
echo "21" > $tmp-exp
./gcd.sh 1071 1029 > $tmp-ans 2>&1 || ERROR_EXIT "error in test11-1"
diff $tmp-ans $tmp-exp > /dev/null || ERROR_EXIT "error in test11-2"

# すべてのテストを通過
rm -f $tmp-*                             # 作ったファイルの削除
echo "all tests passed"                  # 成功メッセージ
exit 0
