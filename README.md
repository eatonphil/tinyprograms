# Tiny Programs

Learning a new language can be hard. Developers go to "Hello World"
but this is so trivial a program so as to be almost useless.

This project is a collection of tiny programs that may help you learn
a language. It is similar to Rosetta Code except that all programs
here will be *implementations* and not library calls.

# Programs

* [Brainfuck](./Brainfuck): A complete Brainfuck implementation
* [Lisp](./Lisp): A tree-walking s-expression interpreter capable of running a fibonacci function
* [UUIDv4](./UUIDv4): A UUIDv4 generator
* Potential:
  * JQ: A tiny JQ clone
  * HTTP: An HTTP server from UNIX sockets
  * RBTree: A red-black tree

# Contributing an implementation

A few rules:

1. Keep it simple and readable.
1. This isn't code golfing.
1. Do not copy any existing code. Write the program from scratch. See
   rule 1.
1. Use existing implementations in this project as guidelines. Use the
   same or similar algorithms and data structures. See rule 1.
1. Avoid programming patterns and object-oriented design and
   functional programming for the sake of patterns and OOP and FP. See
   rule 1.
1. Avoid unnecessarily complex syntax, even if the complex syntax is
   more idiomatic in the language. See rule 1.
1. Copy program.yaml and implement the `prepare` and `run` settings so
   that your implementation is automatically tested in Github Actions.
1. Definitely no 3rd-party libraries. And definitely not builtin
   libraries if they implement the entirety of the program.

Ultimately, Phil is the BDFL and reserves the right to be picky. :)

## Call for languages

* Ada
* FreePascal
* FreeBASIC
* R
* Octave
* Common Lisp
* Swift
* Kotlin
* Scala
* Clojure
* Lua
* C++
* D
* Standard ML
* OCaml
