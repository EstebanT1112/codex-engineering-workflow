from dataclasses import dataclass
from enum import Enum
from typing import Iterable


class OrderStatus(str, Enum):
    PENDING = "pending"
    SHIPPED = "shipped"
    CANCELLED = "cancelled"


@dataclass(frozen=True, slots=True)
class Order:
    order_id: str
    status: OrderStatus


def list_orders(
    orders: Iterable[Order],
    *,
    status: OrderStatus | None = None,
) -> tuple[Order, ...]:
    if status is None:
        return tuple(orders)

    return tuple(order for order in orders if order.status is status)
