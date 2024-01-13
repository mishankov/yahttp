import unittest
import tables

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
