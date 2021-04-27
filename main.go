package main

import (
	"context"
	"log"
	"os"
	"os/signal"
)

func main() {
	log.Println("user starting")
	ctx, ctxDone := context.WithCancel(context.Background())
	done := Start(ctx)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	s := <-c
	ctxDone()
	log.Println("user got signal: " + s.String() + " now closing")
	<-done
}
