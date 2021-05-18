[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-blue.svg)](https://www.gnu.org/software/bash/) ![Generic badge](https://img.shields.io/badge/TL;DR-shell functions to build a basic http server-blue.svg)

# SERTAIN - SERver-side ToolchAIN

This is just a silly project aimed towards quick prototyping and educational purposes. The idea is to enable anyone with only a little familarity with Bash and no knowledge of traditional server-side programming languages such as JS, Go, Python etc., quickly and easily setup a basic rate-limited API or http/1.1 server. Everything is pretty basic. The rate_limiter, for example, simply limits to 1 request per n seconds where n is provided by you.

The main components are bundled inside the `src/` directory. The `etc/` directory contains some essential statically-linked and hence portable binaries of programs that may or may not be needed for your purposes. `examples/` contains handler script(s) for demo and testing. Use these with `src/server` - see [demo](#demo) below.

Everything is self-documented. If anything is still unclear, [write to me](mailto:dey.somajit@gmail.com).

#### Demo:

A simple echo server

1. `cd` to project directory
2. `src/server -p 8080 -s 6 'examples/echo_handler' `
3. Test it with: `curl localhost:8080` or by opening http://localhost:8080 in a browser.

