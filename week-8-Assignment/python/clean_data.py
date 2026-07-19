"""
Part 2: Data Cleaning
Cleans raw CSV files and writes an issues report.
"""

from __future__ import annotations

import re
from datetime import datetime
from pathlib import Path

import pandas as pd

EMAIL_PATTERN = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def _project_root() -> Path:
    return Path(__file__).resolve().parents[1]


def _raw_dir() -> Path:
    return _project_root() / "data" / "raw"


def _clean_dir() -> Path:
    path = _project_root() / "data" / "cleaned"
    path.mkdir(parents=True, exist_ok=True)
    return path


def _reports_dir() -> Path:
    path = _project_root() / "reports"
    path.mkdir(parents=True, exist_ok=True)
    return path


def _parse_order_date(value: str) -> tuple[str | None, str | None]:
    if pd.isna(value) or str(value).strip() == "":
        return None, "empty order_date"

    text = str(value).strip()
    formats = ["%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%d-%m-%Y", "%d/%m/%Y"]
    for fmt in formats:
        try:
            parsed = datetime.strptime(text, fmt)
            if fmt in {"%Y-%m-%d", "%d-%m-%Y", "%d/%m/%Y"}:
                parsed = parsed.replace(hour=0, minute=0, second=0)
            return parsed.strftime("%Y-%m-%d %H:%M:%S"), None
        except ValueError:
            continue
    return None, f"unparseable order_date: {text}"


def clean_orders(df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    cleaned = df.copy()
    issues: list[str] = []

    parsed_dates: list[str | None] = []
    for value in cleaned["order_date"]:
        parsed, issue = _parse_order_date(value)
        parsed_dates.append(parsed)
        if issue:
            issues.append(issue)

    cleaned["order_date"] = parsed_dates
    invalid_dates = cleaned["order_date"].isna().sum()
    if invalid_dates:
        issues.append(f"{invalid_dates} orders have invalid dates after parsing")

    null_mask = cleaned["customer_id"].isna() | cleaned["customer_id"].astype(str).str.upper().eq("NULL") | (
        cleaned["customer_id"].astype(str).str.strip() == ""
    )
    null_count = int(null_mask.sum())
    if null_count:
        issues.append(f"{null_count} orders have missing customer_id")
        cleaned.loc[null_mask, "customer_id"] = pd.NA

    cleaned["customer_id"] = cleaned["customer_id"].astype("string")
    cleaned["status"] = cleaned["status"].astype(str).str.strip().str.upper()
    cleaned["region_code"] = cleaned["region_code"].astype(str).str.strip().str.upper()

    future_mask = pd.to_datetime(cleaned["order_date"], errors="coerce") > pd.Timestamp.now()
    future_count = int(future_mask.sum())
    if future_count:
        issues.append(f"{future_count} orders have future order_date values")

    cleaned = cleaned.dropna(subset=["order_date"]).reset_index(drop=True)
    return cleaned, issues


def clean_products(df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    cleaned = df.copy()
    issues: list[str] = []

    messy_mask = cleaned["product_name"].astype(str).str.strip().ne(
        cleaned["product_name"].astype(str)
    ) | cleaned["product_name"].astype(str).str.lower().ne(
        cleaned["product_name"].astype(str).str.strip().str.title()
    )
    messy_count = int(messy_mask.sum())
    if messy_count:
        issues.append(f"{messy_count} product names required normalization")

    cleaned["product_name"] = (
        cleaned["product_name"].astype(str).str.strip().str.title()
    )
    cleaned["category"] = cleaned["category"].astype(str).str.strip()
    cleaned["subcategory"] = cleaned["subcategory"].astype(str).str.strip()
    cleaned["cost_price"] = pd.to_numeric(cleaned["cost_price"], errors="coerce")

    return cleaned, issues


def validate_emails(customers_df: pd.DataFrame) -> list[str]:
    invalid_ids: list[str] = []
    for _, row in customers_df.iterrows():
        email = str(row["email"]).strip()
        if not EMAIL_PATTERN.match(email):
            invalid_ids.append(str(row["customer_id"]))
    return invalid_ids


def check_referential_integrity(
    orders_df: pd.DataFrame, order_items_df: pd.DataFrame
) -> list[dict]:
    valid_order_ids = set(orders_df["order_id"].astype(str))
    orphans = order_items_df[
        ~order_items_df["order_id"].astype(str).isin(valid_order_ids)
    ]
    return orphans[
        ["item_id", "order_id", "product_id", "quantity", "unit_price", "discount_percent"]
    ].to_dict("records")


def clean_customers(df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    cleaned = df.copy()
    issues: list[str] = []
    invalid_ids = validate_emails(cleaned)
    if invalid_ids:
        issues.append(f"{len(invalid_ids)} customers have invalid emails")
    cleaned["customer_name"] = cleaned["customer_name"].astype(str).str.strip()
    cleaned["email"] = cleaned["email"].astype(str).str.strip().str.lower()
    cleaned["customer_type"] = cleaned["customer_type"].astype(str).str.strip().str.upper()
    cleaned["registration_date"] = pd.to_datetime(
        cleaned["registration_date"], errors="coerce"
    ).dt.strftime("%Y-%m-%d")
    return cleaned, issues


def clean_order_items(df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    cleaned = df.copy()
    issues: list[str] = []

    cleaned["quantity"] = pd.to_numeric(cleaned["quantity"], errors="coerce")
    cleaned["unit_price"] = pd.to_numeric(cleaned["unit_price"], errors="coerce")
    cleaned["discount_percent"] = pd.to_numeric(
        cleaned["discount_percent"], errors="coerce"
    )

    negative_qty = int((cleaned["quantity"] < 0).sum())
    if negative_qty:
        issues.append(f"{negative_qty} order_items have negative quantity (returns)")

    invalid_discount = int((cleaned["discount_percent"] > 100).sum())
    if invalid_discount:
        issues.append(f"{invalid_discount} order_items have discount_percent > 100")

    zero_qty = int((cleaned["quantity"] == 0).sum())
    if zero_qty:
        issues.append(f"{zero_qty} order_items have quantity = 0")

    return cleaned, issues


def write_issues_report(report_lines: list[str]) -> Path:
    report_path = _reports_dir() / "issues_report.txt"
    report_path.write_text("\n".join(report_lines) + "\n", encoding="utf-8")
    return report_path


def main() -> None:
    raw_dir = _raw_dir()
    clean_dir = _clean_dir()

    customers_raw = pd.read_csv(raw_dir / "customers.csv")
    products_raw = pd.read_csv(raw_dir / "products.csv")
    orders_raw = pd.read_csv(raw_dir / "orders.csv")
    order_items_raw = pd.read_csv(raw_dir / "order_items.csv")

    report_lines: list[str] = ["E-Commerce Data Quality Report", "=" * 32, ""]

    customers, customer_issues = clean_customers(customers_raw)
    products, product_issues = clean_products(products_raw)
    orders, order_issues = clean_orders(orders_raw)
    order_items, item_issues = clean_order_items(order_items_raw)

    report_lines.extend(["Customers", "-" * 9])
    report_lines.extend(customer_issues or ["No major customer issues"])
    invalid_emails = validate_emails(customers)
    report_lines.append(f"Invalid email customer_ids: {', '.join(invalid_emails) or 'None'}")
    report_lines.append("")

    report_lines.extend(["Products", "-" * 8])
    report_lines.extend(product_issues or ["No major product issues"])
    report_lines.append("")

    report_lines.extend(["Orders", "-" * 6])
    report_lines.extend(order_issues or ["No major order issues"])
    report_lines.append("")

    report_lines.extend(["Order Items", "-" * 11])
    report_lines.extend(item_issues or ["No major order item issues"])
    report_lines.append("")

    orphans = check_referential_integrity(orders, order_items_raw)
    report_lines.extend(["Referential Integrity", "-" * 21])
    if orphans:
        report_lines.append(f"{len(orphans)} order_items reference missing orders")
        for orphan in orphans[:10]:
            report_lines.append(
                f"  item_id={orphan['item_id']} order_id={orphan['order_id']}"
            )
        if len(orphans) > 10:
            report_lines.append(f"  ... and {len(orphans) - 10} more")
    else:
        report_lines.append("All order_items reference valid orders")
    report_lines.append("")

    # Remove orphan rows from cleaned order_items export.
    valid_order_ids = set(orders["order_id"].astype(str))
    order_items_clean = order_items[
        order_items["order_id"].astype(str).isin(valid_order_ids)
    ].copy()

    customers.to_csv(clean_dir / "customers.csv", index=False)
    products.to_csv(clean_dir / "products.csv", index=False)
    orders.to_csv(clean_dir / "orders.csv", index=False)
    order_items_clean.to_csv(clean_dir / "order_items.csv", index=False)

    report_path = write_issues_report(report_lines)

    print(f"Cleaned files written to: {clean_dir}")
    print(f"Issues report written to: {report_path}")


if __name__ == "__main__":
    main()
