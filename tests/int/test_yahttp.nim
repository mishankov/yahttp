import unittest

include yahttp


test "Test query params":
  let jsonResp = get("http://localhost:8080/get", query = {"param1": "value1", "param2": "value2"}).json()

  check jsonResp["args"]["param1"][0].getStr() == "value1"
  check jsonResp["args"]["param2"][0].getStr() == "value2"
