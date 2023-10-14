package main

import (
	"github.com/DZDomi/ethereum-node-poc/go-monitor/internal/config"
	"github.com/DZDomi/ethereum-node-poc/go-monitor/internal/rpc"
	"github.com/DZDomi/ethereum-node-poc/go-monitor/internal/util"
	"log/slog"
	"time"
)

var rpcClient rpc.Client

func main() {
	cfg, err := config.Load()
	if err != nil {
		util.Fatal("unable to load config", err)
	}

	rpcClient, err = rpc.GetClient(cfg.RPCAddress, cfg.RPCPort)
	if err != nil {
		util.Fatal("unable to get rpc client", err)
	}

	listPeers()
	for range time.Tick(cfg.MonitorInterval) {
		listPeers()
	}
}

func listPeers() {
	peers, err := rpcClient.Peers()
	if err != nil {
		slog.Error("unable to list peers", "err", err)
		return
	}

	slog.Info("connected peers", "count", len(peers))
	for _, peer := range peers {
		slog.Info("connected", "peer", peer.String())
	}
}
