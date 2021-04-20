package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"

	"github.com/labiraus/gomud-common/api"
)

func main() {
	fmt.Println("user starting")
	ctx, ctxDone := context.WithCancel(context.Background())
	done := api.StartBasicApi(ctx, userHandler)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	s := <-c
	ctxDone()
	fmt.Println("user got signal: " + s.String() + " now closing")
	<-done
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	defer func() {
		r := recover()
		if r != nil {
			log.Println(r)
		}
	}()

	var request = userRequest{}
	err := api.UnmarshalRequest(&request, r)
	if err != nil {
		log.Println(err)
		return
	}
	fmt.Printf("user handler got %#v\n", request)

	response := userResponse{Greeting: "from " + request.UserName}
	fmt.Printf("user handler sending %#v\n", response)
	api.MarshalResponse(response, w)
}

type userRequest struct {
	UserName string
}

type userResponse struct {
	Greeting string
}

// Validate checks if it is a valid request
func (r userRequest) Validate() error {
	return nil
}

// Validate checks if it is a valid request
func (r userResponse) Validate() error {
	return nil
}
