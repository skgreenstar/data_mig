#!/bin/bash

# --- 설정 ---
COLLECTOR_URL=${COLLECTOR_URL:-"http://localhost:9000"}
DATA_DIR="collector/data_local"
OUTPUT_DIR="migration_data"

echo "1. 데이터 수집 시작 (Collector API 호출: $COLLECTOR_URL)..."
curl -s -X POST -H "Content-Type: application/json" -d '["rss_news"]' "$COLLECTOR_URL/collect" > /dev/null
curl -s -X POST "$COLLECTOR_URL/setup" > /dev/null
curl -s -X POST "$COLLECTOR_URL/backfill" > /dev/null

echo "2. JSONL 변환 및 데이터브릭스 컬럼 매핑 중..."
mkdir -p "$OUTPUT_DIR"

if ! command -v jq &> /dev/null; then
    echo "[오류] jq가 설치되어 있지 않습니다. 'brew install jq'로 설치해 주세요."
    exit 1
fi

# [Prices] price -> price_usd_bbl 로 변경
if [ -f "$DATA_DIR/prices.json" ]; then
  cat "$DATA_DIR/prices.json" | jq -c '.[] | .price_usd_bbl = .price | del(.price)' > "$OUTPUT_DIR/prices.jsonl"
  echo " - prices.jsonl 생성 완료 (price -> price_usd_bbl 매핑 완료)"
fi

# [News] 그대로 변환
if [ -f "$DATA_DIR/news.json" ]; then
  cat "$DATA_DIR/news.json" | jq -c '.[]' > "$OUTPUT_DIR/news.jsonl"
  echo " - news.jsonl 생성 완료"
fi

# [Macro] 그대로 변환
if [ -f "$DATA_DIR/macro.json" ]; then
  cat "$DATA_DIR/macro.json" | jq -c '.[]' > "$OUTPUT_DIR/macro.jsonl"
  echo " - macro.jsonl 생성 완료"
fi

echo -e "\n완료! 이제 migration_data 폴더를 업로드하고 마이그레이션 스크립트를 실행하세요."
