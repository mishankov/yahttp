import unittest

include yahttp


test "Generate correct basic auth header":
  check ("test login", "test_pass").basicAuthHeader() == "Basic dGVzdCBsb2dpbjp0ZXN0X3Bhc3M="

test "OK response":
  check Response(status: 204).ok()

test "Not OK response":
  check not Response(status: 404).ok()

test "Exception for 4xx and 5xx":
  expect HttpError:
    Response(status: 400).raiseForStatus()

  expect HttpError:
    Response(status: 599).raiseForStatus()

test "Convert to object":
  type T = object
    key: string

  check Response(status: 200, body: "{\"key\": \"value\"}").to(T) == T(key: "value")

test "Parsing an object into a string":
  type MyJson = object
    code: int
    error: bool
    message: string

  let actual = MyJson(code: 400, error: false, message: "test")
  let expected = """{"code":400,"error":false,"message":"test"}"""

  # ToJsonString needs an actual object, it will not work with a JsonNode (%*{})
  check actual.toJsonString() == expected

test "Parse a valid json body from a response":
  let response = Response(status: 200, body: """{"key": "value"}""")

  let actual = response.json()
  let expected = %*{"key": "value"}

  check actual == expected

test "Parsing an invalid json body from a respones raises an error":
  let response = Response(status: 200, body: """{"key": "value""")

  expect JsonParsingError:
    discard response.json()

test "Parse a valid json body and unmarshal it":
  type MyJson = object
    code: int
    error: bool
    message: string

  let response = Response(status: 200, body: """{"code": 200, "error": false, "message": "test"}""")

  let actual = MyJson(code: 200, error: false, message: "test")
  let expected = response.to(MyJson)

  check actual == expected
  check actual is MyJson
