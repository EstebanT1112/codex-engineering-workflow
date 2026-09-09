import unittest

from order_tracker import Order, OrderStatus, list_orders


class ListOrdersTests(unittest.TestCase):
    def setUp(self) -> None:
        self.orders = (
            Order("ORD-001", OrderStatus.PENDING),
            Order("ORD-002", OrderStatus.SHIPPED),
            Order("ORD-003", OrderStatus.PENDING),
        )

    def test_returns_all_orders_when_status_is_omitted(self) -> None:
        self.assertEqual(list_orders(self.orders), self.orders)

    def test_filters_orders_by_status(self) -> None:
        self.assertEqual(
            list_orders(self.orders, status=OrderStatus.PENDING),
            (self.orders[0], self.orders[2]),
        )

    def test_returns_empty_tuple_when_status_has_no_matches(self) -> None:
        self.assertEqual(
            list_orders(self.orders, status=OrderStatus.CANCELLED),
            (),
        )

    def test_does_not_mutate_the_input_collection(self) -> None:
        orders = list(self.orders)
        original = list(orders)

        list_orders(orders, status=OrderStatus.PENDING)

        self.assertEqual(orders, original)


if __name__ == "__main__":
    unittest.main()
