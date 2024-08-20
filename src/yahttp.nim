import base64, httpclient, net, json, uri, strutils, tables, htmlparser, xmltree

import yahttp/internal/utils
import yahttp/exceptions

type
  ## Types without methods
  QueryParam* = tuple[key: string, value: string] ## Type for URL query params
  RequestHeader* = tuple[key: string, value: string] ## Type for HTTP header

  EncodeQueryParams* = object
    ## Parameters for encodeQuery procedure
    usePlus*: bool
    omitEq*: bool
    sep*: char

  MultipartFile* = tuple[multipartName, fileName, contentType,
    content: string] ## Type for uploaded file

  StreamingMultipartFile* = tuple[name, file: string] ## Type for streaming file

  Method* = enum
    ## Supported HTTP methods
    GET, PUT, POST, PATCH, DELETE, HEAD, OPTIONS


type
  BasicAuth* = tuple[login: string, password: string] ## Basic auth type

proc basicAuthHeader(auth: BasicAuth): string =
  return "Basic " & encode(auth.login & ":" & auth.password)

type
  Request* = object
    ## Type to store request information in response
    url*: string
    headers*: seq[tuple[key: string, val: string]]
    httpMethod*: Method
    body*: string

  Response* = object
    ## Type for HTTP response
    status*: int
    body*: string
    headers*: TableRef[string, seq[string]]
    request*: Request

proc toResp(response: httpclient.Response, requestUrl: string,
    requestHeaders: seq[tuple[key: string, val: string]],
        requestHttpMethod: Method, requestBody: string): Response =
  ## Converts httpclient.Response to yahttp.Response
  return Response(
    status: parseInt(response.status.strip()[0..2]),
    headers: response.headers.table,
    body: response.body,
    request: Request(url: requestUrl, headers: requestHeaders,
        httpMethod: requestHttpMethod, body: requestBody)
  )

proc json*(response: Response): JsonNode =
  ## Parses response body to json
  return parseJson(response.body)

proc html*(response: Response): XmlNode =
  ## Parses response body to html
  return parseHtml(response.body)

proc to*[T](response: Response, t: typedesc[T]): T =
  ## Parses response body to json and then casts it to passed type
  return to(response.json(), t)

proc ok*(response: Response): bool =
  ## Is HTTP status in OK range (> 0 and < 400)?
  return response.status > 0 and response.status < 400

proc raiseForStatus*(response: Response) {.raises: [HttpError].} =
  ## Throws `HttpError` exceptions if status is 400 or above
  if response.status >= 400: raise HttpError.newException("Status is: " &
      $response.status)


proc toJsonString*(obj: object): string =
  ## Converts object of any type to json. Helpful to use for `body` argument
  return $ %*obj


const defaultEncodeQueryParams = EncodeQueryParams(usePlus: false, omitEq: true, sep: '&')


proc request*(url: string, httpMethod: Method = Method.GET, headers: openArray[
    RequestHeader] = [], query: openArray[QueryParam] = [],
        encodeQueryParams: EncodeQueryParams = defaultEncodeQueryParams,
        body: string = "", files: openArray[MultipartFile] = [],
            streamingFiles: openArray[StreamingMultipartFile] = [],
    auth: BasicAuth = ("", ""), timeout = -1, ignoreSsl = false,
        sslContext: SslContext = nil): Response =
  ## Genreal proc to make HTTP request with every HTTP method

  # Prepare client

  let client: HttpClient = if sslContext != nil:
      newHttpClient(timeout = timeout, sslContext = sslContext)
    elif ignoreSsl:
      newHttpClient(timeout = timeout, sslContext = newContext(
          verifyMode = CVerifyNone))
    else:
      newHttpClient(timeout = timeout)

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

  let response = if files.len() > 0:
    # Prepare multipart data for files

    var multipartData = newMultipartData()
    for file in files:
      multipartData[file.multipartName] = (file.fileName, file.contentType, file.content)
    client.request(innerUrl, httpMethod = innerMethod,
        multipart = multipartData)
  elif streamingFiles.len() > 0:
    # Prepare multipart data for streaming files

    var multipartData = newMultipartData()
    # for file in streamingFiles:
    multipartData.addFiles(streamingFiles)
    client.request(innerUrl, httpMethod = innerMethod,
        multipart = multipartData)

  else:
    client.request(innerUrl, httpMethod = innerMethod, body = body)

  client.close()

  return response.toResp(requestUrl = innerUrl, requestHeaders = innerHeaders,
      requestHttpMethod = httpMethod, requestBody = body)


# Gnerating procs for individual HTTP methods

http_method_no_body_gen get
http_method_no_body_gen head
http_method_no_body_gen options
http_method_gen put
http_method_gen post
http_method_gen patch
http_method_gen delete
