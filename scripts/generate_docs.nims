import strutils, strformat

let tagsString = gorge("git tag --sort=version:refname")

echo "Tags: ", tagsString

proc generateDocs(tag: string, path: string) =
  echo fmt"Generating docs for tag {tag} to ./../htmldocs/{path}"
  discard gorge(fmt"nim -d:ssl --outdir:./../htmldocs/{path} doc --project  --git.url:https://github.com/mishankov/yahttp --git.commit:{tag} ./../src/yahttp.nim")
  

for tag in tagsString.splitLines():
  if tag.len() > 0:
    generateDocs(tag, tag)

generateDocs("main", "dev");
generateDocs(tagsString.splitLines()[^2], "latest");
