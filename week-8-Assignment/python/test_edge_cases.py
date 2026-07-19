"""
Part 5: Edge Case Handling
Python test functions that verify behavior for problematic input data.
"""

from __future__ import annotations

from datetime import datetime

import pandas as pd


def line_revenue(
    quantity: float,
    unit_price: float,
    discount_percent: float,
    *,
    cap_discount: bool = True,
) -> float:
    discount = discount_percent
    if cap_discount:
        discount = min(max(discount_percent, 0), 100)
    return quantity * unit_price * (1 - discount / 100.0)


def test_orphan_order_items() -> dict:
    orders = pd.DataFrame({"order_id": ["O00001", "O00002"]})
    order_items = pd.DataFrame(
        {
            "item_id": ["I000001", "I000002", "I000003"],
            "order_id": ["O00001", "O00099", "O00002"],
        }
    )

    valid_orders = set(orders["order_id"])
    orphan_items = order_items[~order_items["order_id"].isin(valid_orders)]

    return {
        "orphan_count": len(orphan_items),
        "orphan_order_ids": orphan_items["order_id"].tolist(),
        "expected_action": "Flag orphan rows and exclude them from cleaned exports",
    }


def test_discount_over_100() -> dict:
    discount_percent = 150
    revenue = line_revenue(
        quantity=2, unit_price=100, discount_percent=discount_percent, cap_discount=False
    )
    capped_revenue = line_revenue(
        quantity=2, unit_price=100, discount_percent=discount_percent, cap_discount=True
    )

    return {
        "raw_discount": discount_percent,
        "uncapped_revenue": revenue,
        "capped_revenue": capped_revenue,
        "expected_action": "Cap discount at 100% to avoid negative revenue",
    }


def test_zero_quantity() -> dict:
    revenue = line_revenue(quantity=0, unit_price=250, discount_percent=10)

    return {
        "quantity": 0,
        "revenue": revenue,
        "expected_action": "Revenue becomes 0; row can be kept for audit or filtered out",
    }


def test_future_order_date() -> dict:
    future_date = "2035-12-31 10:00:00"
    parsed = datetime.strptime(future_date, "%Y-%m-%d %H:%M:%S")
    is_future = parsed.date() > datetime.now().date()

    return {
        "order_date": future_date,
        "is_future": is_future,
        "expected_action": "Flag future-dated orders in the quality report",
    }


def run_all_tests() -> None:
    tests = [
        ("Orphan order_items", test_orphan_order_items),
        ("Discount > 100", test_discount_over_100),
        ("Quantity = 0", test_zero_quantity),
        ("Future order_date", test_future_order_date),
    ]

    print("Edge Case Test Results")
    print("=" * 24)
    for name, test_fn in tests:
        result = test_fn()
        print(f"\n{name}")
        for key, value in result.items():
            print(f"  {key}: {value}")


if __name__ == "__main__":
    run_all_tests()
