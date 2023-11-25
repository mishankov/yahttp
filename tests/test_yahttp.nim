import unittest

include yahttp

test "Generate correct basic auth header":
  check ("test login", "test_pass").basicAuthHeader() == "Basic dGVzdCBsb2dpbjp0ZXN0X3Bhc3M="

test "OK response":
  check Response(status: 204).ok()

test "Not OK response":
  check not Response(status: 404).ok()

test "Multiple headers by key":
  const header1: Header = ("header-1", "value-1")
  const header12: Header = ("header-1", "value-2")
  const header2: Header = ("header-2", "value-3")

  const headers: Headers = @[header1, header12, header2]

  check headers["header-1"] == @["value-1", "value-2"]
  check headers["header-2"] == @["value-3"]
