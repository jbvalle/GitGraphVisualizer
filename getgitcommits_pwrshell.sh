git log --pretty=format:'{
  "sha": "%H",
  "commit": {
    "author": {
      "name": "%aN",
      "email": "%aE",
      "date": "%aI"
    },
    "committer": {
      "name": "%cN",
      "email": "%cE",
      "date": "%cI"
    },
    "message": "%s",
    "tree": {
      "sha": "%T"
    }
  },
  "parents": "%P"
}' | ForEach-Object {
  $json = $_ | ConvertFrom-Json
  $json.parents = $json.parents -split ' ' | Where-Object { $_ } | ForEach-Object { @{ sha = $_ } }
  $json
} | ConvertTo-Json -Depth 10
