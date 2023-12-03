import base64, httpclient, net, json, uri, strutils, tables

import yahttp/internal/utils

type
  ## Types without methods
  QueryParam* = tuple[key: string, value: string] ## Type for URL query params
  RequestHeader* = tuple[key: string, value: string] ## Type for HTTP header

  EncodeQueryParams* = object
    ## Parameters for encodeQuery procedure
    usePlus*: bool
    omitEq*: bool
    sep*: char

  Method* = enum
    ## Supported HTTP methods
    GET, PUT, POST, PATCH, DELETE, HEAD, OPTIONS


type
  BasicAuth* = tuple[login: string, password: string] ## Basic auth type

proc basicAuthHeader(auth: BasicAuth): string =
  return "Basic " & encode(auth.login & ":" & auth.password)

type
  Request* = object
    ## Type to store request infornation in response
    url*: string
    headers*: seq[tuple[key: string, val: string]]

  Response* = object
    ## Type for HTTP response
    status*: int
    body*: string
    headers*: TableRef[string, seq[string]]
    request*: Request

proc toResp(response: httpclient.Response, requestUrl: string,
    requestHeaders: seq[tuple[key: string, val: string]]): Response =
  ## Convert httpclient.Response to yahttp.Response
  return Response(
    status: parseInt(response.status.strip()[0..2]),
    headers: response.headers.table,
    body: response.body,
    request: Request(url: requestUrl, headers: requestHeaders)
  )

proc json*(response: Response): JsonNode =
  ## Parses response body to json
  return parseJson(response.body)

proc to*[T](response: Response, t: typedesc[T]): T =
  ## Parses response body to json and then casts it to passed type
  return to(response.json(), t)

proc ok*(response: Response): bool =
  ## Is HTTP status in OK range (> 0 and < 400)?
  return response.status > 0 and response.status < 400


const defaultEncodeQueryParams = EncodeQueryParams(usePlus: false, omitEq: true, sep: '&')


proc request*(url: string, httpMethod: Method = Method.GET, headers: openArray[
    RequestHeader] = [], query: openArray[QueryParam] = [],
        encodeQueryParams: EncodeQueryParams = defaultEncodeQueryParams,
        body: string = "",
    auth: BasicAuth = ("", ""), ignoreSsl = false): Response =
  ## Genreal proc to make HTTP request with every HTTP method

  # Prepare client

  let client: HttpClient = if ignoreSsl:
      newHttpClient(sslContext = newContext(verifyMode = CVerifyNone))
    else:
      newHttpClient()

  # Prepare headers

  var innerHeaders: seq[tuple[key: string, val: string]] = @[]

  for header in headers:
    innerHeaders.add((header.key, header.value))

  if auth.login != "" and auth.password != "":
    innerHeaders.add({"Authorization": auth.basicAuthHeader()})

  if innerHeaders.len() > 0:
    client.headers = newHttpHeaders(innerHeaders)

  # Prepare url

  let innerUrl = if query.len() > 0: url & "?" & encodeQuery(query,
      usePlus = encodeQueryParams.usePlus, omitEq = encodeQueryParams.omitEq,
      sep = encodeQueryParams.sep) else: url

  # Prepare HTTP method

  let innerMethod: HttpMethod = case httpMethod:
    of Method.GET: HttpGet
    of Method.PUT: HttpPut
    of Method.POST: HttpPost
    of Method.PATCH: HttpPatch
    of Method.DELETE: HttpDelete
    of Method.HEAD: HttpHead
    of Method.OPTIONS: HttpOptions

  # Make request

  let response = client.request(innerUrl, httpMethod = innerMethod, body = body)
  client.close()

  return response.toResp(requestUrl = innerUrl, requestHeaders = innerHeaders)


# Gnerating procs for individual HTTP methods

http_method_no_body_gen get
http_method_no_body_gen head
http_method_no_body_gen options
http_method_gen put
http_method_gen post
http_method_gen patch
http_method_gen delete
