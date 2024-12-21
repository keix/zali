# Tiny Lisp Interpreter in Zig
This repository contains a simple Lisp interpreter written in Zig. It is designed to demonstrate core Lisp concepts and serve as a learning tool for both Lisp and Zig programming. This implementation supports basic Lisp functionality, making it an excellent starting point for exploring both languages.

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


## Compatibility

This project has been tested and confirmed to work on the following environment:
- Zig 0.14.0-dev.2178+bd7dda0c5
- Gentoo Linux 6.6.32 (x86_64)

This project has been tested on Gentoo Linux. While it should work on other Linux distributions, macOS, and Windows, these platforms have not been thoroughly tested.

## Getting Started

Prerequisites
- Zig Compiler version 0.13.0 or later

Build and Run
- Clone the repository:

```bash
git clone https://github.com/keix/tiny-lisp.git
cd tiny-lisp
```

Build the interpreter:

```bash
zig build
```

Run a Lisp script:

```bash
./zig-out/bin/lisp script/fizzbuzz.lisp
```

## Acknowledgments
Inspired by the simplicity and elegance of Lisp and the modern design of Zig.
Thanks to the Zig and Lisp hackers for their support and resources.

## License
This project is licensed under the MIT License. Copyright (c) 2024 Kei Sawamura a.k.a. keix


