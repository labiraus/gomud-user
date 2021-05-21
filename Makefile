generate:
	buf generate --template buf.grpc.yaml --path proto/gomud-user https://github.com/labiraus/gomud-common.git 
	buf generate --template buf.gen.yaml --path proto/gomud-api https://github.com/labiraus/gomud-common.git
	cd proto
	go mod tidy

gateway:
	protoc-gen-grpc-gateway