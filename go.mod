module github.com/labiraus/gomud-user

go 1.16

require (
	github.com/labiraus/gomud-user/api v0.0.0-20210427080541-99008353b4d7
	golang.org/x/net v0.0.0-20210423184538-5f58ad60dda6 // indirect
	golang.org/x/sys v0.0.0-20210426230700-d19ff857e887 // indirect
	google.golang.org/genproto v0.0.0-20210426193834-eac7f76ac494 // indirect
	google.golang.org/grpc v1.37.0
)

replace github.com/labiraus/gomud-user/api => ./api