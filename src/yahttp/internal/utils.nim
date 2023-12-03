import macros, strutils

macro http_method_gen*(name: untyped): untyped =
  let methodName = newIdentNode(name.strVal().toUpper())
  quote do:
    proc `name`*(url: string, headers: openArray[RequestHeader] = [], query: openArray[
      QueryParam] = [], encodeQueryParams: EncodeQueryParams = defaultEncodeQueryParams, body: string = "", auth: BasicAuth = ("", ""),
      ignoreSsl = false): Response =
      return request(
        url = url,
        httpMethod = Method.`methodName`,
        headers = headers,
        query = query,
        body = body,
        auth = auth,
        ignoreSsl = ignoreSsl
      )


macro http_method_no_body_gen*(name: untyped): untyped =
  let methodName = newIdentNode(name.strVal().toUpper())
  quote do:
    proc `name`*(url: string, headers: openArray[RequestHeader] = [], query: openArray[
        QueryParam] = [], encodeQueryParams: EncodeQueryParams = defaultEncodeQueryParams, auth: BasicAuth = ("", ""), ignoreSsl = false): Response =
      return request(
        url = url,
        httpMethod = Method.`methodName`,
        headers = headers,
        query = query,
        auth = auth,
        ignoreSsl = ignoreSsl
      )
