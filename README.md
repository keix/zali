# Tiny Lisp Interpreter in Zig
This repository contains a simple Lisp interpreter written in Zig. It is designed to demonstrate core Lisp concepts and serve as a learning tool for both Lisp and Zig programming. This implementation supports basic Lisp functionality, making it an excellent starting point for exploring both languages.

## Features
- Basic Lisp Data Types:
    - Atom types: Numbers, Symbols, Strings, and Booleans
    - List types: Standard Lisp lists and cons cells

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
    - List operations: cons, car, cdr

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

```

## Compatibility

This project has been tested and confirmed to work on the following environment:
- Zig 0.14.0-dev.2178+bd7dda0c5
- Gentoo Linux 6.6.32 (x86_64)

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

## Development Notes
- Memory Management:
    - Implements a custom allocator to manage memory for Lisp objects.
    - Detects memory leaks and cleans up allocated resources.

- Extensibility:
    - Add new built-in functions by modifying the builtins array.
    - Extend the LispValue union to include more data types as needed.

## Acknowledgments
Inspired by the simplicity and elegance of Lisp and the modern design of Zig.
Thanks to the Zig and Lisp communities for their support and resources.











