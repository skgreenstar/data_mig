#!/bin/bash

# --- 설정 (실행 시점에 환경 변수로 입력받음) ---
# 예: DATABRICKS_WAREHOUSE_ID=xxx ./migrate_to_databricks.sh
CATALOG=${DATABRICKS_CATALOG:-"main"}
SCHEMA=${DATABRICKS_SCHEMA:-"strategic_ai"}
WAREHOUSE_ID=${DATABRICKS_WAREHOUSE_ID}
TARGET_PATH="dbfs:/tmp/strategic_ai"
INPUT_DIR="migration_data"

# 필수값 체크
if [ -z "$WAREHOUSE_ID" ]; then
  echo "[오류] DATABRICKS_WAREHOUSE_ID 환경 변수가 설정되지 않았습니다."
  echo "사용법: DATABRICKS_WAREHOUSE_ID=내_ID ./migrate_to_databricks.sh"
  exit 1
fi

if [ ! -d "$INPUT_DIR" ]; then
  echo "[오류] $INPUT_DIR 폴더를 찾을 수 없습니다. 먼저 export_local_data.sh를 실행해 주세요."
  exit 1
fi

echo "1. 데이터브릭스 DBFS로 파일 업로드 중 ($TARGET_PATH)..."
# databricks cli 설치 여부 확인
if ! command -v databricks &> /dev/null; then
    echo "[오류] databricks cli가 설치되어 있지 않습니다."
    exit 1
fi

databricks fs cp --recursive "$INPUT_DIR/" "$TARGET_PATH"

echo -e "\n2. 데이터브릭스 Delta 테이블로 마이그레이션 실행 ($CATALOG.$SCHEMA)..."

for table in prices news macro gpr scenarios; do
  echo " - $table 데이터 로딩 중..."
  databricks sql execute --warehouse-id "$WAREHOUSE_ID" --statement "
    COPY INTO $CATALOG.$SCHEMA.$table
    FROM '$TARGET_PATH/$table.jsonl'
    FILEFORMAT = JSON
    FORMAT_OPTIONS ('ignoreChanges' = 'true')
    COPY_OPTIONS ('mergeSchema' = 'true');"
done

echo -e "\n마이그레이션 작업이 완료되었습니다!"
