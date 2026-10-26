package rpc

type Request struct {
	JsonRPC string `json:"jsonrpc"`
	ID      uint   `json:"id"`
	Method  string `json:"method"`
}

type PeerResult struct {
	Enode   string `json:"enode"`
	Name    string `json:"name"`
	Network struct {
		RemoteAddress string `json:"remoteAddress"`
	} `json:"network"`
}

type AdminPeerResponse struct {
	JsonRPC string       `json:"jsonrpc"`
	Id      int          `json:"id"`
	Result  []PeerResult `json:"result"`
}
