package rpc

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/DZDomi/ethereum-node-poc/go-monitor/internal/domain"
	"io"
	"log/slog"
	"net/http"
	"net/url"
)

type Client interface {
	Peers() ([]domain.Peer, error)
}

type client struct {
	httpClient *http.Client
	targetUrl  *url.URL

	logger *slog.Logger
}

func GetClient(address string, port uint) (Client, error) {
	parsedURl, err := url.Parse(fmt.Sprintf("http://%s:%d", address, port))
	if err != nil {
		return nil, err
	}

	return &client{
		httpClient: &http.Client{
			Timeout: defaultTimeout,
		},
		targetUrl: parsedURl,
		logger:    slog.With("module", "rpc"),
	}, nil
}

func (c *client) Peers() ([]domain.Peer, error) {
	var response AdminPeerResponse
	err := c.doRequest(1, "admin_peers", &response)
	if err != nil {
		return nil, err
	}

	peers := make([]domain.Peer, 0)
	for _, peerResult := range response.Result {
		peers = append(peers, domain.Peer{
			Client:        peerResult.Name,
			Enode:         peerResult.Enode,
			RemoteAddress: peerResult.Network.RemoteAddress,
		})
	}
	return peers, nil
}

func (c *client) prepareRequest(id uint, method string) (io.Reader, error) {
	preparedRequest := Request{
		JsonRPC: defaultJsonRPCVersion,
		ID:      id,
		Method:  method,
	}
	marshalledResponse, err := json.Marshal(preparedRequest)
	if err != nil {
		return nil, err
	}
	return bytes.NewReader(marshalledResponse), nil
}

func (c *client) doRequest(id uint, method string, data any) error {
	request, err := c.prepareRequest(id, method)
	if err != nil {
		return err
	}
	response, err := c.httpClient.Post(c.targetUrl.String(), defaultContentType, request)
	if err != nil {
		return err
	}

	defer func(body io.ReadCloser) {
		if err != nil {
			err = errors.Join(err, body.Close())
		} else {
			err = body.Close()
		}
	}(response.Body)
	body, err := io.ReadAll(response.Body)
	if err != nil {
		return err
	}

	err = json.Unmarshal(body, &data)
	// Note: This is needed for the defer method
	return err
}
