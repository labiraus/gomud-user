package main

import (
	"context"
	"log"
	"net"

	pb "github.com/labiraus/gomud-user/api/internal"
	"google.golang.org/grpc"
)

const (
	port = ":8080"
)

// server is used to implement helloworld.GreeterServer.
type server struct {
	pb.UnimplementedGreeterServer
}

// SayHello implements helloworld.GreeterServer
func (s *server) SayHello(ctx context.Context, request *pb.HelloRequest) (*pb.HelloReply, error) {
	log.Printf("Received: %v", request.GetName())
	return &pb.HelloReply{Greeting: "from " + request.GetName()}, nil
}

func Start(ctx context.Context) <-chan struct{} {
	done := make(chan struct{})
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
		close(done)
	}
	s := grpc.NewServer()
	go func() {
		defer close(done)
		pb.RegisterGreeterServer(s, &server{})
		if err := s.Serve(lis); err != nil {
			log.Fatalf("failed to serve: %v", err)
		}
	}()
	go func() {
		<-ctx.Done()
		s.Stop()
	}()
	return done
}
