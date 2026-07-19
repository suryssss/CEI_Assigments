"""
Part 1: Data Generation
Generates 4 CSV files with realistic fake e-commerce data and intentional quality issues.
"""

from __future__ import annotations

import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

RANDOM_SEED = 42
NUM_CUSTOMERS = 550
NUM_PRODUCTS = 550
NUM_ORDERS = 600
NUM_ORDER_ITEMS = 1200

STATUSES = ["PLACED", "SHIPPED", "DELIVERED", "CANCELLED", "RETURNED"]
REGIONS = ["US-EAST", "US-WEST", "EU-NORTH", "EU-SOUTH", "APAC", "LATAM"]
CUSTOMER_TYPES = ["REGULAR", "PREMIUM", "VIP"]

CATEGORIES = {
    "Electronics": ["Phones", "Laptops", "Audio", "Accessories"],
    "Clothing": ["Shirts", "Pants", "Shoes", "Outerwear"],
    "Home": ["Kitchen", "Furniture", "Decor", "Cleaning"],
    "Books": ["Fiction", "Non-Fiction", "Education", "Comics"],
}

FIRST_NAMES = [
    "Ava", "Noah", "Mia", "Liam", "Sophia", "Ethan", "Isabella", "Lucas",
    "Amelia", "Mason", "Harper", "Logan", "Ella", "James", "Grace", "Benjamin",
]
LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
    "Davis", "Rodriguez", "Martinez", "Wilson", "Anderson", "Taylor", "Thomas",
]
PRODUCT_ADJECTIVES = ["Pro", "Ultra", "Classic", "Essential", "Premium", "Lite"]
DOMAINS = ["mail.com", "shopmail.net", "customer.io", "inbox.org"]


def _project_root() -> Path:
    return Path(__file__).resolve().parents[1]


def _output_dir() -> Path:
    path = _project_root() / "data" / "raw"
    path.mkdir(parents=True, exist_ok=True)
    return path


def _random_datetime(start: datetime, end: datetime) -> datetime:
    delta = end - start
    seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=seconds)


def _maybe_messy_product_name(base_name: str) -> str:
    if random.random() < 0.08:
        return f"  {base_name.upper() if random.random() < 0.5 else base_name.lower()}  "
    return base_name


def _maybe_invalid_email(name_part: str) -> str:
    if random.random() < 0.02:
        invalid_type = random.choice(["missing_at", "missing_domain"])
        if invalid_type == "missing_at":
            return f"{name_part}.{random.randint(100, 999)}mail.com"
        return f"{name_part}@{random.randint(100, 999)}"
    return f"{name_part}@{random.choice(DOMAINS)}"


def _format_order_date(dt: datetime, use_wrong_format: bool) -> str:
    if use_wrong_format:
        return dt.strftime("%d-%m-%Y")
    return dt.strftime("%Y-%m-%d %H:%M:%S")


def generate_customers() -> list[dict]:
    rows: list[dict] = []
    start = datetime(2022, 1, 1)
    end = datetime(2025, 6, 30, 23, 59, 59)

    for i in range(1, NUM_CUSTOMERS + 1):
        first = random.choice(FIRST_NAMES)
        last = random.choice(LAST_NAMES)
        name_part = f"{first.lower()}.{last.lower()}{i}"
        rows.append(
            {
                "customer_id": f"C{i:04d}",
                "customer_name": f"{first} {last}",
                "email": _maybe_invalid_email(name_part),
                "registration_date": _random_datetime(start, end).strftime("%Y-%m-%d"),
                "customer_type": random.choices(
                    CUSTOMER_TYPES, weights=[0.6, 0.3, 0.1], k=1
                )[0],
            }
        )
    return rows


def generate_products() -> list[dict]:
    rows: list[dict] = []
    product_counter = 1

    for category, subcategories in CATEGORIES.items():
        for subcategory in subcategories:
            for _ in range(max(30, NUM_PRODUCTS // (len(CATEGORIES) * 4))):
                if product_counter > NUM_PRODUCTS:
                    break
                base_name = (
                    f"{random.choice(PRODUCT_ADJECTIVES)} "
                    f"{subcategory} {product_counter}"
                )
                cost = round(random.uniform(5, 250), 2)
                rows.append(
                    {
                        "product_id": f"P{product_counter:04d}",
                        "product_name": _maybe_messy_product_name(base_name),
                        "category": category,
                        "subcategory": subcategory,
                        "cost_price": cost,
                    }
                )
                product_counter += 1

    return rows[:NUM_PRODUCTS]


def generate_orders(customers: list[dict]) -> list[dict]:
    rows: list[dict] = []
    start = datetime(2023, 1, 1)
    end = datetime(2025, 6, 30, 23, 59, 59)
    customer_ids = [row["customer_id"] for row in customers]
    null_customer_indices = set(
        random.sample(range(NUM_ORDERS), k=max(1, int(NUM_ORDERS * 0.05)))
    )
    wrong_date_indices = set(
        random.sample(range(NUM_ORDERS), k=max(1, int(NUM_ORDERS * 0.04)))
    )

    for i in range(1, NUM_ORDERS + 1):
        idx = i - 1
        order_dt = _random_datetime(start, end)
        customer_id = ""
        if idx in null_customer_indices:
            customer_id = random.choice(["NULL", "", ""])
        else:
            customer_id = random.choice(customer_ids)

        rows.append(
            {
                "order_id": f"O{i:05d}",
                "customer_id": customer_id,
                "order_date": _format_order_date(
                    order_dt, use_wrong_format=idx in wrong_date_indices
                ),
                "status": random.choices(
                    STATUSES, weights=[0.15, 0.2, 0.45, 0.1, 0.1], k=1
                )[0],
                "region_code": random.choice(REGIONS),
            }
        )
    return rows


def generate_order_items(orders: list[dict], products: list[dict]) -> list[dict]:
    rows: list[dict] = []
    order_ids = [row["order_id"] for row in orders]
    product_ids = [row["product_id"] for row in products]
    negative_indices = set(
        random.sample(range(NUM_ORDER_ITEMS), k=max(1, int(NUM_ORDER_ITEMS * 0.03)))
    )

    # Ensure every order has at least one line item; add extra items for basket analysis.
    item_counter = 1
    for order in orders:
        items_in_order = random.randint(1, 4)
        chosen_products = random.sample(
            product_ids, k=min(items_in_order, len(product_ids))
        )
        for product_id in chosen_products:
            quantity = random.randint(1, 5)
            if (item_counter - 1) in negative_indices:
                quantity = -random.randint(1, 3)

            product = next(p for p in products if p["product_id"] == product_id)
            markup = random.uniform(1.15, 1.8)
            unit_price = round(float(product["cost_price"]) * markup, 2)

            rows.append(
                {
                    "item_id": f"I{item_counter:06d}",
                    "order_id": order["order_id"],
                    "product_id": product_id,
                    "quantity": quantity,
                    "unit_price": unit_price,
                    "discount_percent": round(random.uniform(0, 25), 2),
                }
            )
            item_counter += 1
            if item_counter > NUM_ORDER_ITEMS:
                break
        if item_counter > NUM_ORDER_ITEMS:
            break

    # Add a few orphan items for referential integrity testing.
    orphan_count = 5
    for i in range(orphan_count):
        rows.append(
            {
                "item_id": f"I{item_counter:06d}",
                "order_id": f"O{NUM_ORDERS + i + 1:05d}",
                "product_id": random.choice(product_ids),
                "quantity": random.randint(1, 3),
                "unit_price": round(random.uniform(10, 200), 2),
                "discount_percent": round(random.uniform(0, 20), 2),
            }
        )
        item_counter += 1

    return rows


def write_csv(path: Path, rows: list[dict], fieldnames: list[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    random.seed(RANDOM_SEED)
    output_dir = _output_dir()

    customers = generate_customers()
    products = generate_products()
    orders = generate_orders(customers)
    order_items = generate_order_items(orders, products)

    write_csv(
        output_dir / "customers.csv",
        customers,
        ["customer_id", "customer_name", "email", "registration_date", "customer_type"],
    )
    write_csv(
        output_dir / "products.csv",
        products,
        ["product_id", "product_name", "category", "subcategory", "cost_price"],
    )
    write_csv(
        output_dir / "orders.csv",
        orders,
        ["order_id", "customer_id", "order_date", "status", "region_code"],
    )
    write_csv(
        output_dir / "order_items.csv",
        order_items,
        ["item_id", "order_id", "product_id", "quantity", "unit_price", "discount_percent"],
    )

    print(f"Generated data in: {output_dir}")
    print(f"  customers.csv     : {len(customers)} rows")
    print(f"  products.csv      : {len(products)} rows")
    print(f"  orders.csv        : {len(orders)} rows")
    print(f"  order_items.csv   : {len(order_items)} rows")


if __name__ == "__main__":
    main()
