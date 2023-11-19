# Package

version       = "0.1.0"
author        = "Denis Mishankov"
description   = "Awesome simple HTTP client"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"

task docs, "Genreate docs":
    exec "nim doc src/yahttp.nim"
