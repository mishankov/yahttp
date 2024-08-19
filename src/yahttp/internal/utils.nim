import macros, strutils, strformat

macro http_method_gen*(name: untyped): untyped =
  let methodUpper = name.strVal().toUpper()
  let methodName = newIdentNode(methodUpper)
  let comment = newCommentStmtNode(fmt"Proc for {methodUpper} HTTP method")
  quote do:
    proc `name`*(url: string, headers: openArray[RequestHeader] = [], query: openArray[
      QueryParam] = [], encodeQueryParams: EncodeQueryParams = defaultEncodeQueryParams, body: string = "", files: openArray[tuple[name, fileName, contentType, content: string]] = [], auth: BasicAuth = ("", ""), timeout = -1,
      ignoreSsl = false, sslContext: SslContext = nil): Response =
      `comment`
      return request(
        url = url,
        httpMethod = Method.`methodName`,
        headers = headers,
        query = query,
        body = body,
        files = files,
        auth = auth,
        timeout = timeout,
        ignoreSsl = ignoreSsl,
        sslContext = sslContext
      )


macro http_method_no_body_gen*(name: untyped): untyped =
  let methodUpper = name.strVal().toUpper()
  let methodName = newIdentNode(methodUpper)
  let comment = newCommentStmtNode(fmt"Proc for {methodUpper} HTTP method")
  quote do:
    proc `name`*(url: string, headers: openArray[RequestHeader] = [], query: openArray[
        QueryParam] = [], encodeQueryParams: EncodeQueryParams = defaultEncodeQueryParams, auth: BasicAuth = ("", ""), timeout = -1, ignoreSsl = false, sslContext: SslContext = nil): Response =
      `comment`
      return request(
        url = url,
        httpMethod = Method.`methodName`,
        headers = headers,
        query = query,
        auth = auth,
        timeout = timeout,
        ignoreSsl = ignoreSsl,
        sslContext = sslContext
      )
