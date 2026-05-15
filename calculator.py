"""Simple calculator."""

while (expr := input("Calc> ").strip()) != "q":
    try:
        a, op, b = expr.split()
        a, b = float(a), float(b)
        print({"+": a + b, "-": a - b, "*": a * b, "/": a / b}[op])
    except Exception as e:
        print(f"Error: {e}")
