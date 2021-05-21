generate:
	buf generate --path proto/gomud-user https://github.com/labiraus/gomud-common.git
	cd proto
	go mod tidy

gateway:
	protoc-gen-grpc-gateway