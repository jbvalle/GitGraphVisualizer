#!/bin/bash
git log --all --pretty=format:'%H%x00%T%x00%an%x00%ae%x00%aI%x00%cn%x00%ce%x00%cI%x00%B%x00%P%x00' | jq -R -s '
  # Split by null bytes and remove last empty element
  split("\u0000") | 
  .[0:-1] | 
  
  # Group into chunks of 10 fields per commit
  [ 
    range(0; length; 10) as $i | 
    .[$i: $i+10] 
  ] | 
  
  # Process each commit
  map(
    {
      sha: .[0],
      tree_sha: .[1],
      author_name: .[2],
      author_email: .[3],
      author_date: .[4],
      committer_name: .[5],
      committer_email: .[6],
      committer_date: .[7],
      message: (.[8] | rtrimstr("\n")),  # Remove trailing newline
      parent_hashes: .[9]
    }
  ) |
  
  # Build final structure
  map({
    sha: .sha,
    commit: {
      author: {
        name: .author_name,
        email: .author_email,
        date: .author_date
      },
      committer: {
        name: .committer_name,
        email: .committer_email,
        date: .committer_date
      },
      message: .message,
      tree: { sha: .tree_sha }
    },
    parents: (
      .parent_hashes | 
      if . == "" then []
      else split(" ") | map({sha: .})
      end
    )
  })
'
