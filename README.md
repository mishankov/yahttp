# ⛵ yahttp - Awesome simple HTTP client for Nim

[![GitHub Release](https://img.shields.io/github/v/release/mishankov/yahttp?sort=semver&display_name=tag&logo=nim&label=latest%20release&color=%23FFE953)](https://github.com/mishankov/yahttp/releases/latest)
[![CI](https://github.com/mishankov/yahttp/actions/workflows/ci.yml/badge.svg)](https://github.com/mishankov/yahttp/actions/workflows/ci.yml)


- Based on Nim [std/httpclient](https://nim-lang.org/docs/httpclient.html)
- No additional dependencies
- API focused on DX

# Installation

```shell
nimble install yahttp
```

# Examples

> more examples [here](examples/examples.nim)

## Get HTTP status code

```nim
import yahttp

echo get("https://www.google.com/").status
```
## Send query params and parse response to JSON

```nim
import json
import yahttp

let laptopsJson = get("https://dummyjson.com/products/search", query = {"q": "Laptop"}).json()
echo laptopsJson["products"][0]["title"].getStr()
```
# API

## Method procedures

```nim
get("http://api")
put("http://api")
post("http://api")
patch("http://api")
delete("http://api")
head("http://api")
options("http://api")
```
Arguments:
- `url` - request URL. The only required argument
- `headers` - request HTTP headers. Example: `{"header1": "val", "header2": "val2"}`
- `query` - request query params. Example: `{"param1": "val", "param2": "val2"}`
- `encodeQueryParams` - parameters for `encodeQuery` function that encodes query params. [More](https://nim-lang.org/docs/uri.html#encodeQuery%2CopenArray%5B%5D%2Cchar)
- `body` - request body as a string. Example: `"{\"key\": \"value\"}"`. Is not available for `get`, `head` and `options` procedures
- `files` - array of files to upload. Every file is a tuple of multipart name, file name, content type and content
- `sreamingFiles` - array of files to stream from disc and upload. Every file is a tuple of multipart name and file path
- `auth` - login and password for basic authorization. Example: `("login", "password")`
- `timeout` - stop waiting for a response after a given number of milliseconds. `-1` for no timeout, which is default value
- `ignoreSsl` - no certificate verification if `true`
- `sslContext` - SSL context for TLS/SSL connections. See [newContext](https://nim-lang.org/docs/net.html#newContext%2Cstring%2Cstring%2Cstring%2Cstring)

## General procedure

```nim
request("http://api")
```

Has the same arguments as method procedures and one additional:
- `httpMethod` - HTTP method. `Method.GET` by default. Example: `Method.POST`

## Response object

All procedures above return `Response` object with fields:
- `status` - HTTP status code
- `body` - response body as a string
- `headers` - table, where keys are header keys and values are sequences of header values for a key
- `request` - object with request data processed by `yahttp`
  - `url` - stores full url with query params
  - `headers` - stores HTTP headers with `Authorization` for basic authorization
  - `httpMethod` - HTTP method
  - `body` - request body as a string

`Response` object has some helper procedures:
- `Response.json()` - returns response body as JSON
- `Response.html()` - returns response body as HTML
- `Response.to(t)` - converts response body to JSON and unmarshals it to type `t`
- `Response.ok()` - returns `true` if `status` is greater than 0 and less than 400
- `Response.raiseForStatus()` - throws `HttpError` exceptions if status is 400 or above

## Other helper functions

`object.toJsonString()` - converts object of any type to json string. Helpful to use for `body` argument
