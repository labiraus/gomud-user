package main

import "testing"

func Test_setGreeting(t *testing.T) {
	//Arrange
	request := userRequest{UserName: "fred"}

	//Act
	response := setGreeting(request)

	//Assert
	if response.Greeting != "from fred" {
		t.Errorf("expected: 'from fred' got: '%v'", response.Greeting)
	}
}
