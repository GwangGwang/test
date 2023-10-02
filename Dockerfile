FROM --platform=$BUILDPLATFORM golang:1.21.0-alpine3.18 AS builder

RUN apk add --no-cache --update make git
RUN apk add upx~=4 --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community