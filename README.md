# ZALI — Zig-Assembly Lisp Interpreter
ZALI is a small Lisp interpreter written in Zig.

## Dependencies
- Zig compiler 0.14.1+

## Features
- Basic Lisp Data Types:
    - Atom types: Numbers, Symbols, Strings, and Booleans
    - List types: Standard Lisp lists

- Parsing:
    - Parses input strings into an Abstract Syntax Tree (AST)
    - Handles numbers, strings, symbols, and lists
    - Detects and reports syntax errors (e.g., unmatched parentheses)

- Built-in Functions:
    - Arithmetic operations: +, -, *, /, mod
    - Comparison operations: =, <=, >=
    - Logical operations: and
    - Conditional branching: if, cond
    - Variable definition and assignment: define, set!
    - Loops: while
    - Output: print

- Environment and Scope:
    - Supports variable management and name resolution
    - Implements lexical scoping for functions and variables

- Error Handling:
    - Parses errors (e.g., invalid syntax, unmatched parentheses)
    - Evaluation errors (e.g., type errors, unknown symbols)
    - Meaningful error messages for debugging


## Getting Started

Prerequisites
- Zig Compiler version 0.14.1

Build and Run
- Clone the repository:

```bash
git clone https://github.com/keix/zali.git
zig build
./zig-out/bin/zali script/fizzbuzz.lisp
```

## Example Script

Here's an example of a FizzBuzz implementation in Lisp, which the interpreter can evaluate:

```lisp
(define i 1)
(while (<= i 100)
    (cond
        (and (= (mod i 3) 0) (= (mod i 5) 0)) (print "FizzBuzz")
        (= (mod i 3) 0)                       (print "Fizz")
        (= (mod i 5) 0)                       (print "Buzz")
        #t                                    (print i))
    (set! i (+ i 1)))
```

### Lisp Scripts
ZALI was tested with the following scripts:  
- https://github.com/keix/zali/tree/main/scripts

```zsh
for i in `ls scripts/`                                                                                                                                                                                                                                                                                                ─╯
do
    ./zig-out/bin/zali scripts/$i
done
```

## Acknowledgments
Respect to the elegance of Lisp and the modern design of Zig. Thanks to the Zig and Lisp communities for their tools and insights.

## License
This project is licensed under the MIT License. Copyright (c) 2024 Kei Sawamura a.k.a. keix


