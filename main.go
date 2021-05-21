package main

import (
	"context"
	"log"
	"os"
	"os/signal"

	"github.com/labiraus/gomud-user/pkg/greeting"
)

//go:generate make generate

func main() {
	log.Println("user starting")
	ctx, ctxDone := context.WithCancel(context.Background())
	done := greeting.Start(ctx)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	s := <-c
	ctxDone()
	log.Println("user got signal: " + s.String() + " now closing")
	<-done
}
