#!/bin/bash
aftman install
wally install
rojo sourcemap sourcemap-dev.project.json > ./sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/