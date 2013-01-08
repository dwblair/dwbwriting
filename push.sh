#!/bin/bash

runghc hakyll.hs build
git add .
git commit -a -m "Automatic push"
git push
cp -R _site/* ../dwblair.github.com
cd ../dwblair.github.com
git add .
git commit -a -m "Automatic push"
git push --force

