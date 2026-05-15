"""Simple calculator with basic arithmetic operations."""


def add(a: float, b: float) -> float:
    return a + b


def subtract(a: float, b: float) -> float:
    return a - b


def multiply(a: float, b: float) -> float:
    return a * b


def divide(a: float, b: float) -> float:
    if b == 0:
        raise ZeroDivisionError("Cannot divide by zero")
    return a / b


OPERATIONS = {
    "+": add,
    "-": subtract,
    "*": multiply,
    "/": divide,
}


def main() -> None:
    print("=== Simple Calculator ===")
    print("Operations: +, -, *, /")
    print("Type 'q' to quit.\n")

    while True:
        expr = input("Enter expression (e.g. 2 + 3): ").strip()
        if expr.lower() == "q":
            print("Goodbye!")
            break

        parts = expr.split()
        if len(parts) != 3:
            print("Error: please enter in format: <number> <op> <number>")
            continue

        try:
            a = float(parts[0])
            op = parts[1]
            b = float(parts[2])
        except ValueError:
            print("Error: invalid number")
            continue

        if op not in OPERATIONS:
            print(f"Error: unknown operation '{op}'. Use +, -, *, /")
            continue

        try:
            result = OPERATIONS[op](a, b)
            print(f"Result: {result}\n")
        except ZeroDivisionError as e:
            print(f"Error: {e}\n")


if __name__ == "__main__":
    main()
