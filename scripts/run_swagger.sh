#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

if [ -z "$(docker images -q docker.swagger.io/swaggerapi/swagger-ui 2> /dev/null)" ]; then
  docker pull docker.swagger.io/swaggerapi/swagger-ui
fi

docker run -t -i -p 3001:8080 \
  --add-host=host.docker.internal:host-gateway \
  -e SWAGGER_JSON=/var/specs/openapi.json \
  -v $SCRIPT_DIR/..:/var/specs \
  docker.swagger.io/swaggerapi/swagger-ui
