#!/bin/bash

THING_NAME=thing-1
SHADOW_NAME=shadow-1
COMMAND=$1

update_state() {
    MODE=$1
    aws iot-data update-thing-shadow --thing-name $THING_NAME --shadow-name $SHADOW_NAME \
        --cli-binary-format raw-in-base64-out \
        --payload "{\"state\":{\"desired\":{\"mode\":\"$MODE\"}}}" /dev/stdout \
        | jq .
}

get_state() {
    aws iot-data get-thing-shadow --thing-name $THING_NAME --shadow-name $SHADOW_NAME /dev/stdout | jq .
}

case $COMMAND in
    "desired")
        update_state $2
        ;;
    "get")
        get_state
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Usage: $0 desired <state> OR $0 get"
        exit 1
        ;;
esac

