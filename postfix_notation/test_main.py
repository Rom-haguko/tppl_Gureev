import pytest
from main import (
    parse_number,
    do_operation,
    do_tilde,
    calculate_postfix,
)


@pytest.fixture
def stacks():
    s1 = [10, 3, 8]
    s2 = [3, 0, 4]
    return s1, s2


class TestPostfix:

    def test_parse_number(self):
        assert parse_number("42") == 42
        assert parse_number("3.5") == 3.5
        assert parse_number("5.0") == 5
        with pytest.raises(ValueError):
            parse_number("abc")

    def test_addition_and_subtraction(self):
        assert do_operation("+", 2, 3) == 5
        assert do_operation("+", 2.5, 1.5) == 4
        assert do_operation("-", 10, 4) == 6
        assert do_operation("-", 4, 10) == -6

    def test_multiplication_and_division(self):
        assert do_operation("*", 3, 4) == 12
        assert do_operation("/", 10, 2) == 5
        assert do_operation("/", 10, 3) == pytest.approx(3.3, 0.1)
        with pytest.raises(ZeroDivisionError):
            do_operation("/", 10, 0)

    def test_tilde(self, stacks):
        s1, s2 = stacks
        do_tilde(s1)
        assert s1 == [10, 5]

        do_tilde(s2)
        assert s2 == [49]

        with pytest.raises(ValueError):
            do_tilde([1])

    @pytest.mark.parametrize(
        "expression,expected",
        [
            ("3 0 4 ~ 2 ~", 47),
            ("2 2 + 4 - 4 ~ 2 3 * +", 22),
            ("15 3 / 2 +", 7),
            ("2.5 2 * 1 -", 4),
        ]
    )
    def test_calculate_postfix(self, expression, expected):
        assert calculate_postfix(expression) == expected

    def test_calculate_errors(self):
        with pytest.raises(ValueError):
            calculate_postfix("   ")
        with pytest.raises(ValueError):
            calculate_postfix("5 +")
        with pytest.raises(ValueError):
            calculate_postfix("2 3 4 +")