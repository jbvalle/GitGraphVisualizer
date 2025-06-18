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
    "message": "%s"
  },
  "parents": [
    %p
  ]
},' | sed '$ s/,$//' | jq -s .
