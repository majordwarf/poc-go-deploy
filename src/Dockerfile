# Build stage
FROM golang:1.13.15-alpine3.12 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN apk add --update make git
RUN VERSION=$(git rev-parse --verify HEAD) make build

# Runtime stage
FROM alpine:3.12
LABEL maintainer="Tejas Tank <tejastank10@gmail.com>"
USER 1000
COPY --from=builder /app/demo.bin ./demo
ENTRYPOINT ["./demo"]