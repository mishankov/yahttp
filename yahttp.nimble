# Package

version       = "0.7.0"
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
