import sys


def parse_number(token: str):
    """Превращает символ в число (int или float)."""
    try:
        if "." in token:
            num = float(token)
            return int(num) if num % 1 == 0 else num
        return int(token)
    except ValueError:
        raise ValueError(
            f"неизвестный символ '{token}'. используйте только числа и операторы (+, -, *, /, ~)."
        )


def do_operation(operator: str, x, y):
    """ операции +, -, *, / """
    if operator == "+":
        res = x + y
    elif operator == "-":
        res = x - y
    elif operator == "*":
        res = x * y
    else:
        if y == 0:
            raise ZeroDivisionError("на ноль делить нельзя!")
        res = x / y

    return int(res) if res % 1 == 0 else res


def do_tilde(stack: list):
    """ операция ~ """
    if len(stack) < 2:
        raise ValueError("недостаточно чисел в стеке для выполнения операции '~'")

    y = stack.pop()
    x = stack.pop()

    if x != 0 and y != 0:
        res = abs(x - y)
    else:
        total_sum = sum(stack) + x + y
        stack.clear()
        res = total_sum ** 2

    stack.append(int(res) if res % 1 == 0 else res)


def calculate_postfix(expression: str):
    """ вычисляет потсфиксное выражение """
    tokens = expression.split()

    if not tokens:
        raise ValueError("пустое выражение! введите числа и операторы.")

    stack = []

    for token in tokens:
        if token in ("+", "-", "*", "/"):
            if len(stack) < 2:
                raise ValueError(f"недостаточно чисел в стеке для выполнения операции '{token}'")
            y = stack.pop()
            x = stack.pop()
            stack.append(do_operation(token, x, y))
        elif token == "~":
            do_tilde(stack)
        else:
            stack.append(parse_number(token))

        print(f"Шаг '{token}': стек = {stack}")

    if len(stack) != 1:
        raise ValueError("в выражении слишком много чисел и не хватает операторов для получения одного ответа.")

    return stack[0]


if __name__ == "__main__":  # pragma: no cover
    if len(sys.argv) < 2:
        print("привет! Я заботливая стековая машина.")
        print("выражение не передано")
        print('пример правильного запуска: python main.py "3 0 4 ~ 2 ~"')
        sys.exit(1)

    expression = " ".join(sys.argv[1:])

    try:
        result = calculate_postfix(expression)
        print(f"{expression} = {result}")
    except (ValueError, ZeroDivisionError) as error:
        print(f"произошла ошибка (заботливое замечание): {error}")
        sys.exit(1)