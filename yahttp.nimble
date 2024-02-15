# Package

version       = "0.10.0"
author        = "Denis Mishankov"
description   = "Awesome simple HTTP client"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"

task docs, "Genreate docs":
    exec "nim doc src/yahttp.nim"

task pretty, "Pretty":
    exec "nimpretty src/yahttp.nim"

task examples, "Run examples":
    exec "nim c --run examples/examples.nim"

task unittests, "Run unit tests":
    exec "testament pattern \"tests/unit/*.nim\""

task inttests, "Run integation tests":
    exec "docker run -d --name yahttp-httpbin -p 8080:8080 mccutchen/go-httpbin" 
    exec "testament pattern \"tests/int/*.nim\""
    exec "docker stop yahttp-httpbin"
    exec "docker remove yahttp-httpbin"
