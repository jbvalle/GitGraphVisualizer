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
}' | jq -s 'map(.parents |= (split(" ") | map(select(. != "") | {sha: .})))'
