#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

if [ -z "$(docker images -q mermade/openapi-gui 2> /dev/null)" ]; then
  docker pull mermade/openapi-gui
fi

docker run -p 8080:3000 mermade/openapi-gui
