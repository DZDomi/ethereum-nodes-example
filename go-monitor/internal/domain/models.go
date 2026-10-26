package domain

import (
	"fmt"
)

type Peer struct {
	Client        string
	Enode         string
	RemoteAddress string
}

func (p Peer) String() string {
	return fmt.Sprintf("client=%s enode=%s remote-address=%s", p.Client, p.Enode, p.RemoteAddress)
}
