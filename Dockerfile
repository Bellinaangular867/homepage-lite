# Build stage
FROM golang:1.25-alpine AS builder

# Build args for version info
ARG VERSION=dev
ARG GIT_COMMIT=unknown

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the binary with ldflags
RUN BUILD_TIME=$(date -u +'%Y-%m-%dT%H:%M:%SZ') && GO_VERSION=$(go version | cut -d ' ' -f 3) && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "-s -w -X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME} -X main.GitCommit=${GIT_COMMIT} -X main.GoVersion=${GO_VERSION}" -o homepage-lite .

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/homepage-lite .

# Expose port (default 8888 from README)
EXPOSE 8888

# Run the binary
CMD ["./homepage-lite","--config","/app/config/config.yaml"]
