"""
Load cleaned CSV files into a local SQLite database.
"""

from __future__ import annotations

import csv
import sqlite3
from pathlib import Path


def project_root() -> Path:
    return Path(__file__).resolve().parents[1]


def db_path() -> Path:
    path = project_root() / "db" / "ecommerce.db"
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def cleaned_dir() -> Path:
    return project_root() / "data" / "cleaned"


def load_database(force_recreate: bool = True) -> Path:
    database = db_path()
    if force_recreate and database.exists():
        database.unlink()

    conn = sqlite3.connect(database)
    try:
        schema_sql = (project_root() / "sql" / "create_tables.sql").read_text(
            encoding="utf-8"
        )
        conn.executescript(schema_sql)

        data_dir = cleaned_dir()
        for table in ["customers", "products", "orders", "order_items"]:
            csv_file = data_dir / f"{table}.csv"
            if not csv_file.exists():
                raise FileNotFoundError(
                    f"Missing cleaned file: {csv_file}. Run clean_data.py first."
                )

            with csv_file.open("r", encoding="utf-8", newline="") as handle:
                reader = csv.DictReader(handle)
                if reader.fieldnames is None:
                    raise ValueError(f"No header found in {csv_file}")

                columns = reader.fieldnames
                placeholders = ",".join(["?"] * len(columns))
                insert_sql = (
                    f"INSERT INTO {table} ({','.join(columns)}) VALUES ({placeholders})"
                )

                rows = []
                for row in reader:
                    parsed = []
                    for column in columns:
                        value = row[column]
                        if value in {"", "NULL", "null"}:
                            parsed.append(None)
                        else:
                            parsed.append(value)
                    rows.append(parsed)

                conn.executemany(insert_sql, rows)

        conn.commit()
    finally:
        conn.close()

    return database


def main() -> None:
    database = load_database()
    conn = sqlite3.connect(database)
    try:
        counts = {}
        for table in ["customers", "products", "orders", "order_items"]:
            counts[table] = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    finally:
        conn.close()

    print(f"SQLite database created at: {database}")
    for table, count in counts.items():
        print(f"  {table}: {count} rows")


if __name__ == "__main__":
    main()
