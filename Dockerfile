ARG TARGETOS
ARG TARGETARCH
ARG BUILD_IMAGE=golang:1.22.4-alpine
ARG BASE_IMAGE=gcr.io/distroless/static:nonroot

FROM --platform=$BUILDPLATFORM ${BUILD_IMAGE} AS builder
RUN mkdir /build
WORKDIR /build
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download
COPY main.go main.go
COPY internal/ internal/
COPY pkg/ pkg/
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -installsuffix 'static' -o spegel .

FROM ${BASE_IMAGE}
COPY --from=builder /build/spegel /app/
WORKDIR /app
USER root:root
ENTRYPOINT ["./spegel"]
