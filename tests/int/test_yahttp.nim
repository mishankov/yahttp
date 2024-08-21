import unittest
import json

include yahttp


const BASE_URL = "http://localhost:8080"
const INT_TESTS_BASE_PATH = "tests/int"

test "Test HTTP methods":
  check get(BASE_URL & "/get").ok()
  check head(BASE_URL & "/head").ok()
  check put(BASE_URL & "/put").ok()
  check post(BASE_URL & "/post").ok()
  check patch(BASE_URL & "/patch").ok()
  check delete(BASE_URL & "/delete").ok()

test "Test query params":
  let jsonResp = get(BASE_URL & "/get", query={"param1": "value1", "param2": "value2"}).json()

  check jsonResp["args"]["param1"][0].getStr() == "value1"
  check jsonResp["args"]["param2"][0].getStr() == "value2"

test "Test headers":
  let jsonResp = get(BASE_URL & "/headers", headers={"header1": "value1", "header2": "value2"}).json()

  check jsonResp["headers"]["Header1"][0].getStr() == "value1"
  check jsonResp["headers"]["Header2"][0].getStr() == "value2"

test "Test auth header":
  let jsonResp = get(BASE_URL & "/headers", auth=("test login", "test_pass")).json()

  check jsonResp["headers"]["Authorization"][0].getStr() == "Basic dGVzdCBsb2dpbjp0ZXN0X3Bhc3M="

test "Test body":
  let jsonResp = put(BASE_URL & "/put", headers = {"Content-Type": "text/plain"}, body = "some body").json()

  check jsonResp["data"].getStr() == "some body"

test "Test JSON body":
  let jsonResp = put(BASE_URL & "/put", headers = {"Content-Type": "application/json"}, body = $ %*{"key": "value"}).json()

  check jsonResp["json"]["key"].getStr() == "value"

test "Test body with toJsonString helper":
  type TestReq = object
    field1: string
    field2: int

  let jsonResp = put(BASE_URL & "/put", headers = {"Content-Type": "application/json"}, body = TestReq(field1: "value1", field2: 123).toJsonString()).json()

  check jsonResp["json"]["field1"].getStr() == "value1"
  check jsonResp["json"]["field2"].getInt() == 123

test "Test timeout":
  expect TimeoutError:
    discard get(BASE_URL & "/delay/5", timeout = 100)

  # No exception
  discard get(BASE_URL & "/delay/5", timeout = -1)


test "Test sending single file":
  let resp = post(BASE_URL & "/post", files = @[("my_file", "test.txt", "text/plain", "some file content")]).json()
  
  check resp["files"]["my_file"][0].getStr() == "some file content"
  check resp["data"].getStr().contains("test.txt")
  check resp["data"].getStr().contains("text/plain")
  check resp["data"].getStr().contains("some file content")

test "Test sending multiple files":
  let resp = post(BASE_URL & "/post", files = @[("my_file", "test.txt", "text/plain", "some file content"), ("my_second_file", "test2.txt", "text/plain", "second file content")]).json()
  
  check resp["files"]["my_file"][0].getStr() == "some file content"
  check resp["files"]["my_second_file"][0].getStr() == "second file content"
  check resp["data"].getStr().contains("test.txt")
  check resp["data"].getStr().contains("text/plain")
  check resp["data"].getStr().contains("some file content")
  check resp["data"].getStr().contains("test2.txt")
  check resp["data"].getStr().contains("text/plain")
  check resp["data"].getStr().contains("second file content")


const TEST_FILE_PATH_1 = INT_TESTS_BASE_PATH & "/test_data/test_file_1.txt"
const TEST_FILE_CONTENT_1 = readFile(TEST_FILE_PATH_1)

const TEST_FILE_PATH_2 = INT_TESTS_BASE_PATH & "/test_data/test_file_2.txt"
const TEST_FILE_CONTENT_2 = readFile(TEST_FILE_PATH_2)

test "Test streaming single file":
  let resp = post(BASE_URL & "/post", streamingFiles = @[("my_file", TEST_FILE_PATH_1)]).json()

  check resp["files"]["my_file"][0].getStr() == TEST_FILE_CONTENT_1
  check resp["data"].getStr().contains("test_file_1.txt")
  check resp["data"].getStr().contains("text/plain")
  check resp["data"].getStr().contains(TEST_FILE_CONTENT_1)

test "Test streaming multiple files":
  let resp = post(BASE_URL & "/post", streamingFiles = @[("my_file", TEST_FILE_PATH_1), ("my_second_file", TEST_FILE_PATH_2)]).json()

  check resp["files"]["my_file"][0].getStr() == TEST_FILE_CONTENT_1
  check resp["files"]["my_second_file"][0].getStr() == TEST_FILE_CONTENT_2
  check resp["data"].getStr().contains("test_file_1.txt")
  check resp["data"].getStr().contains("text/plain")
  check resp["data"].getStr().contains(TEST_FILE_CONTENT_1)
  check resp["data"].getStr().contains("test_file_2.txt")
  check resp["data"].getStr().contains("text/plain")
  check resp["data"].getStr().contains(TEST_FILE_CONTENT_2)
