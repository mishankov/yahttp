import unittest
import tables

include yahttp

test "Generate correct basic auth header":
  check ("test login", "test_pass").basicAuthHeader() == "Basic dGVzdCBsb2dpbjp0ZXN0X3Bhc3M="

test "OK response":
  check Response(status: 204).ok()

test "Not OK response":
  check not Response(status: 404).ok()

test "Iterate over headers":
  const headers = [("header-1", @["value-1", "value-2"]), ("header-2", @["value-3"])]

  let headersTable: Headers = newTable(headers)
  var headersSeq: seq[Header] = @[]
  for header in headersTable: headersSeq.add(header)

  check headersSeq == @[("header-1", "value-1"), ("header-1", "value-2"), ("header-2", "value-3")]
