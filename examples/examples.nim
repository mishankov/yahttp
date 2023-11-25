import json
import yahttp

# Getting cat tags as JSON
let catTags = get("https://cataas.com/api/tags").json()

# Loop through first 5 cat tags and if tag is not empty string get data of a couple of cats with this tag
for catTag in catTags[0..4]:
  let tag = catTag.getStr()

  if tag.len() > 0:
    echo "===="
    echo "Working with tag " & tag
    let catData = get("https://cataas.com/api/cats", query = {"tags": tag, "limit": "10"})
    
    echo "Request URL: ", catData.request.url
    echo "Response status: ", catData.status
    echo "Response headers: ", catData.headers
    echo "Response body: ", catData.body
