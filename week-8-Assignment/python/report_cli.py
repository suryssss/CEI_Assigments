"""
Part 4: Python + SQL Integration
Command-line reporting tool using only the sqlite3 standard library.
"""

from __future__ import annotations

import sqlite3
from datetime import datetime, timedelta
from pathlib import Path


def project_root() -> Path:
    return Path(__file__).resolve().parents[1]


def database_path() -> Path:
    return project_root() / "db" / "ecommerce.db"


def revenue_expression(alias: str = "oi") -> str:
    return (
        f"{alias}.quantity * {alias}.unit_price "
        f"* (1 - {alias}.discount_percent / 100.0)"
    )


def parse_date(value: str) -> datetime:
    for fmt in ("%Y-%m-%d", "%d-%m-%Y", "%Y-%m-%d %H:%M:%S"):
        try:
            return datetime.strptime(value.strip(), fmt)
        except ValueError:
            continue
    raise ValueError(f"Invalid date format: {value}")


def normalize_range(start_input: str, end_input: str) -> tuple[str, str]:
    start = parse_date(start_input)
    end = parse_date(end_input)
    if end < start:
        raise ValueError("End date must be on or after start date.")
    return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")


def previous_period(start: str, end: str, report_type: str) -> tuple[str, str]:
    start_dt = datetime.strptime(start, "%Y-%m-%d")
    end_dt = datetime.strptime(end, "%Y-%m-%d")
    period_days = (end_dt - start_dt).days + 1

    if report_type == "daily":
        prev_end = start_dt - timedelta(days=1)
        prev_start = prev_end
    elif report_type == "weekly":
        prev_end = start_dt - timedelta(days=1)
        prev_start = prev_end - timedelta(days=period_days - 1)
    elif report_type == "monthly":
        prev_end = start_dt - timedelta(days=1)
        prev_start = prev_end - timedelta(days=period_days - 1)
    else:
        raise ValueError("Report type must be daily, weekly, or monthly.")

    return prev_start.strftime("%Y-%m-%d"), prev_end.strftime("%Y-%m-%d")


def fetch_summary(conn: sqlite3.Connection, start: str, end: str) -> dict:
    revenue_sql = revenue_expression()
    summary = conn.execute(
        f"""
        SELECT
            COUNT(DISTINCT o.order_id) AS total_orders,
            ROUND(COALESCE(SUM({revenue_sql}), 0), 2) AS total_revenue,
            COUNT(DISTINCT o.customer_id) AS unique_customers
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE date(o.order_date) BETWEEN ? AND ?
        """,
        (start, end),
    ).fetchone()

    top_products = conn.execute(
        f"""
        SELECT
            p.product_name,
            ROUND(SUM({revenue_sql}), 2) AS product_revenue
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE date(o.order_date) BETWEEN ? AND ?
        GROUP BY p.product_name
        ORDER BY product_revenue DESC
        LIMIT 3
        """,
        (start, end),
    ).fetchall()

    return {
        "total_orders": summary[0],
        "total_revenue": summary[1],
        "unique_customers": summary[2],
        "top_products": top_products,
    }


def percent_change(current: float, previous: float) -> float | None:
    if previous == 0:
        return None
    return round(((current - previous) / previous) * 100, 2)


def format_report(
    report_type: str,
    start: str,
    end: str,
    current: dict,
    previous: dict,
) -> str:
    lines = [
        "=" * 60,
        f"{report_type.upper()} REPORT",
        f"Date Range: {start} to {end}",
        "=" * 60,
        "",
        "Summary",
        "-" * 7,
        f"Total Orders       : {current['total_orders']}",
        f"Total Revenue      : {current['total_revenue']}",
        f"Unique Customers   : {current['unique_customers']}",
        "",
        "Top 3 Products",
        "-" * 14,
    ]

    if current["top_products"]:
        for rank, (name, revenue) in enumerate(current["top_products"], start=1):
            lines.append(f"{rank}. {name} - {revenue}")
    else:
        lines.append("No product sales in this period.")

    lines.extend(["", "Comparison With Previous Period", "-" * 31])

    metrics = [
        ("Orders", current["total_orders"], previous["total_orders"]),
        ("Revenue", current["total_revenue"], previous["total_revenue"]),
        ("Unique Customers", current["unique_customers"], previous["unique_customers"]),
    ]

    for label, curr_value, prev_value in metrics:
        change = percent_change(float(curr_value), float(prev_value))
        if change is None:
            lines.append(f"{label}: previous period had no data")
        else:
            sign = "+" if change >= 0 else ""
            lines.append(f"{label}: {sign}{change}%")

    lines.append("")
    return "\n".join(lines)


def generate_report(report_type: str, start: str, end: str) -> str:
    db_file = database_path()
    if not db_file.exists():
        raise FileNotFoundError(
            f"Database not found at {db_file}. Run load_database.py first."
        )

    start_date, end_date = normalize_range(start, end)
    prev_start, prev_end = previous_period(start_date, end_date, report_type)

    conn = sqlite3.connect(db_file)
    try:
        current = fetch_summary(conn, start_date, end_date)
        previous = fetch_summary(conn, prev_start, prev_end)
    finally:
        conn.close()

    return format_report(report_type, start_date, end_date, current, previous)


def main() -> None:
    print("E-Commerce Summary Report Tool")
    print("Report types: daily | weekly | monthly")
    report_type = input("Enter report type: ").strip().lower()
    start = input("Enter start date (YYYY-MM-DD): ").strip()
    end = input("Enter end date (YYYY-MM-DD): ").strip()

    try:
        report = generate_report(report_type, start, end)
    except ValueError as exc:
        print(f"Error: {exc}")
        return

    print(report)


if __name__ == "__main__":
    main()
