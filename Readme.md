![Charm Logo](https://raw.githubusercontent.com/Aearnus/charm/master/imgs/Charm.png)

<p align="center">
   Chat with us at <br>
   <a href="https://discord.gg/RQu5adW">
      <img src="https://raw.githubusercontent.com/Aearnus/charm/master/imgs/Discord.png">
   </a>
</p>

**Charm** is an experimental stack based functional language based off of Forth and Joy. It implements functions as a first class data structure, able to be manipulated with ease, using generally applicable tools and functions.

## :boom: Why use Charm? :question:

```
" hello " " world " concat pstring                      => hello world
```

* **Lispiness**: All code is data and all data is code. With this comes very powerful tooling for metaprogramming and surprising abstractions.
* **Functionality**: Everything written in Charm is a function; no "if"s, "and"s, nor "but"s. Functions can either perform upon the stack or the state (such as `dup`, the function to duplicate the top value on the stack), or evaluate to themselves (such as `3`, which is a function to push the integer `3` onto the stack).
* **Simplicity**: There is little syntactic cruft. The only significant syntax in Charm ` `, `:=`, `"`, and `[ ]`. This means that your code can, largely, read however you want it and makes defining DSLs extremely easy.
* **Speed**: Speed takes a forefront in the Charm interpreter, with stack manipulation code running at near native speed for comparable operations. Additionally, any truly performance critical sections of your code can be written using the C++ FFI and run directly inside of Charm.


Example REPL session:

```
tyler@nasa:~/scripts/charm$ ./charm
Charm Interpreter v0.0.1
Made by @Aearnus
Looking for Prelude.charm...
Prelude.charm loaded.

Charm$ addOneToN := " n " getref 1 + " n " flip setref
Charm$ putN := " n " getref put pop
Charm$ putN
0
Charm$ addOneToN putN
1
Charm$ [ addOneToN ] 10 repeat
Charm$ put
[ addOneToN addOneToN addOneToN addOneToN addOneToN addOneToN addOneToN addOneToN addOneToN addOneToN ]
Charm$ i
Charm$ putN
11
```

## Quick Links

- Esolangs Wiki: https://esolangs.org/wiki/Charm
- Charm Glossary: https://aearnus.github.io/charm/
- Charm Prelude: https://github.com/Aearnus/charm/blob/master/Prelude.charm.cpp

## Dependencies

- GCC (>7.0.0) or Clang (>4.0)
- libreadline and related development packages (`libreadline-dev on apt-based systems`)
- A willingness to think outside of the box

To run all the tests...

- A recent version of GHC

## Compilation

Build and install Charm with:
```
make
sudo make install
```
This will produce a binary named `charm`, and copy it to `/usr/bin/charm`.

To install Charm development libraries (especially for the Charm FFI), build and install with:
```
make ffi-lib
sudo make install-lib
```
This will install `libcharmffi.a` to `/usr/lib/` and include headers to `/usr/include/charm/`. See `test/test-ffi/testLib.cpp` for an example of how to use the main include header, `charm/CharmFFI.h`.

### Compilation Options

* `GUI=true`: Builds Charm with the ncurses based GUI by [Iconmaster](https://github.com/iconmaster5326). This is **highly** recommended, as it is immensely useful!

* `DEBUG=true`: Builds Charm with verbose debug mode enabled.

* `USE_READLINE=false`: Builds Charm without GNU readline support.

### Compilation note for Raspberry Pi users

The built-in dynamic version of `libstdc++` (located at `/usr/lib/arm-linux-gnueabihf/libstdc++.so.6`) isn't new enough to support the modern C++17 features used in Charm. Consequently, to compile Charm on a Raspberry Pi, make sure to use static linking against the compiler provided version of `libstdc++` through the command
```
make CPPFLAGS=-static-libstdc++
```
Do note that you still need either GCC (>7.0.0) or Clang (>4.0) to compile on a Raspberry Pi.

## About Charm

### Full Charm Function Glossary

This is an autogenerated file created from a list of every function in Charm. Browse it as a reference or as a quick overview of what the language is capable of!

https://aearnus.github.io/charm/

At the top, there is a short description of the language and a table of contents. Click through the table of contents to reach the functions themselves, where you can find out what they do and

### Basic syntax and implementation

Charm has an extremely simple syntax. Everything is space delimited (even the list and string constructs), and there are only four syntax rules outside of left to right evaluation. Those four rules are:
* Type signatures
    * Type signatures are defined using the syntax `<function name> :: <popped types> -> <pushed types> | [alternate signature]`. Do note that it is not neccesary to have an alternate signature.
    * For example, the type signature of `dup` is `dup :: any -> any any`.
* Function definition
    * Functions are defined using the syntax `<function name> := <function body>`.
    * Do note that functions can also be defined with the `def` function.
    * Tail call recursive functions are optimized away and allow for basic loop structures in Charm.
* Lists
    * Lists are defined using the syntax `[ <elements> ]`.
    * Lists are, as everything else, space delimited. An example of a properly defined list is `[ 1 2 3 ]`.
* Strings
    * Strings are defined using the syntax `" <string> "`.
    * While the inside of a string is parsed literally, the special `"` tokens require a space to be parsed. The rational behind this is that (for simplicity's sake) everything in Charm is an unambiguous token. Thus, omitting the space around the `"` tokens in a string causes the parser to consume a normal function that simply has quotes in the name of it.
    * An example of a properly defined string is `" Hello, world! "`. This is equivalent to `"Hello, world!"` in a C-like language.
    * Strings have a few different escape codes that you can use, such as `\"` to escape a quote or `\n` to escape a newline. The full list can be found in [this source file](https://github.com/Aearnus/charm/blob/master/Parser.cpp#L245), in the function `Parser::escapeString(std::string tok)`.


Everything in Charm is a function, and there are four types of functions. These are:
* Number functions (`3`, `-0.2`, `50000`)
    * Internally represented as either a `long long` or a `long double`.
* List functions (`[ 1 2 3 4 ]`, `[ i put pop q ]`)
* String functions (`" Hello! "`, `" \t I'm indented! "`)
    * Internally represented as a `std::string`.
* Defined functions (`map`, `repeat`, `dup`)

Many functions are preprogrammed (in C++) into Charm. This includes object and stack manipulation, arithmetic, and some combinators. But, others are in the standard library of Charm, called `Prelude.charm`. The glossary explains functions with its arguments using calling order, placing the deepest value on the stack first. This mirrors how it would be written with Charm itself.

### About optimization

Charm uses a self-written optimizing interpreter. I'm very interested in the use cases and the effectiveness of the optimizations. The interpreter performs two optimizations: inlining and tail-call.

Inlining optimization is enabled by default through the compilation option `-DOPTIMIZE_INLINE=true`. Inlining optimization occurs if the interpreter detects that a function isn't recursive. If it isn't, the interpreter writes in the contents of the function wherever it is called, instead of writing the function itself (like a text macro). This removes 1 (or more, depending on how deep the inlining goes) layer of function redirection.

Tail-call optimization is necessary for this language, as there are no other ways to achieve a looping construct but recursion. There are a few cases which get tail-call optimized into a loop. These few cases are:

* `f := <code> f`
* `f := [ <cond> ] [ <code> f ] [ <code> ] ifthen`
* `f := [ <cond> ] [ <code> ] [ <code> f ] ifthen`
* `f := [ <cond> ] [ <code> f ] [ <code> f ] ifthen` (gets unrolled into a loop of the first form, ends up looking like `f := [ <cond> ] [ <code> ] [ <code> ] ifthen f`)

(If you can think of any other cases or a more general case, please open an issue!). These optimizations should allow for looping code that does not smash the calling stack and significant speedups. If there are any cases where these optimizations seem to be causing incorrect side effects, please create an issue or get into contact with me.


## SUPPORT OR DONATE

### Todo list

- ~~C FFI & linkage~~ Done!
- ~~Imports from other files~~ Done!
- Type signatures
- Possible C++ codegen?

### Other Links

[Open an issue](https://github.com/Aearnus/charm/issues/new) or [DM me on Twitter](https://twitter.com/aearnus).
