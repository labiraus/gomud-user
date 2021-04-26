ARG  BUILDER_IMAGE=golang:alpine
############################
# STEP 1 build executable binary
############################
FROM ${BUILDER_IMAGE} as builder

# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates

# Create appuser
ENV USER=appuser
ENV UID=10001

# See https://stackoverflow.com/a/55757473/12429735
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR $GOPATH/src/app/

# Add protobuf compile tool
RUN apk add protobuf
RUN go get \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
    google.golang.org/protobuf/cmd/protoc-gen-go \
    google.golang.org/grpc/cmd/protoc-gen-go-grpc \
    github.com/mwitkow/go-proto-validators/protoc-gen-govalidators

RUN export PATH="$PATH:$(go env GOPATH)/bin"

# Pre populate with go modules installed
COPY go.mod .
COPY go.sum .
COPY ./api/go.mod /api/
COPY ./api/go.sum /api/
ENV GO111MODULE=on
RUN go mod download
RUN go mod verify

# Copy source code from local directories
COPY . .

# Ensure that the proto files are up to date
RUN protoc -I=api --go_out=api --go_opt=paths=source_relative --go-grpc_out=api --go-grpc_opt=paths=source_relative api/*/*/*.proto

# Run unit tests before building
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go test . ./...

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' -a \
    -o /go/bin/app .

############################
# STEP 2 build a small image
############################
FROM scratch
EXPOSE 8080

# Import from builder.
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy our static executable
COPY --from=builder /go/bin/app /go/bin/app

# Use an unprivileged user.
USER appuser:appuser

# Run the app binary.
ENTRYPOINT ["/go/bin/app"]
