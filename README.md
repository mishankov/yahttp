# ⛵ yahttp - Awesome simple HTTP client for Nim 

[![CI](https://github.com/mishankov/yahttp/actions/workflows/ci.yml/badge.svg)](https://github.com/mishankov/yahttp/actions/workflows/ci.yml)


- Based on Nim [std/httpclient](https://nim-lang.org/docs/httpclient.html)
- No additional dependencies
- API focused on DX

# Installation
> nimble package manager release coming soon

```shell
nimble install https://github.com/mishankov/yahttp
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
- `body` - request body as a string. Example: `"{\"key\": \"value\"}\"`. Is not available for `get`, `head` and `options` procedures
- `auth` - login and password for basic authentication. Example: `("login", "password")`
- `ignoreSsl` - no certificate verification if `true`

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
- `headers` - sequence of response headers

`Response` object has some helper procedures:
- `Response.json()` - returns response body as JSON
- `Response.to(t)` - converts response body to JSON and unmarshals it to type `t`
- `Response.ok()` - returns `true` if `status` is greater than 0 and less than 400
