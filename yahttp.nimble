# Package

version       = "0.4.0"
author        = "Denis Mishankov"
description   = "Awesome simple HTTP client"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.12"

task docs, "Genreate docs":
    exec "nim doc src/yahttp.nim"

task pretty, "Pretty":
    exec "nimpretty src/yahttp.nim"

task examples, "Run examples":
    exec "nim c --run examples/examples.nim "
