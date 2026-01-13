#!/bin/bash

# this script is for building .png diagrams from 
# the mermaid .mmd text files.
# the mermaid cli is installed dev dependency via npm.
#
# this script just runs mmdc to build a .png file 
# in /images for each .mmd file in /diagrams
#
# https://github.com/mermaid-js/mermaid-cli
# npm install -D @mermaid-js/mermaid-cli
# mmdc -i input.mmd -o output.png -t forest

src_dir=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

for file in "${src_dir}"/assets/diagrams/*.mmd
do
  basename="$(basename -- $file)"
  basename_png=${basename%.mmd}.png
  echo $( \
    mmdc \
      -i "${file}" \
      -o "${src_dir}"/assets/images/"${basename_png}"\
      -t forest \
  )
done