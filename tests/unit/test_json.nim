import unittest

include yahttp

suite "toJsonString Test Suite":
    test "Simple Case":
        let sample = %*{"name": "Alice", "age": 30}
        let expected = """{"name":"Alice","age":30}"""
        check toJsonString(sample) == expected

    test "Empty JSON":
        let empty = %*{}
        let expected = """{}"""
        check toJsonString(empty) == expected

    test "Nested JSON":
        let nested = %*{
            "user": {
                "name": "Bob",
                "location": {"city": "Paris", "country": "France"}
            }
        }
        let expected = """{"user":{"name":"Bob","location":{"city":"Paris","country":"France"}}}"""
        check toJsonString(nested) == expected