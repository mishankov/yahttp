import strutils, strformat

let tagsString = gorge("git tag --sort=version:refname")

for tag in tagsString.splitLines():
  if tag.len() > 0:
    echo gorge(fmt"nim -d:ssl --outdir:./../htmldocs/{tag} doc --project  --git.url:https://github.com/mishankov/yahttp --git.commit:{tag} ./../src/yahttp.nim")
