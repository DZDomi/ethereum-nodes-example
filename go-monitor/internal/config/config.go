package config

import (
	"github.com/caarlos0/env/v9"
	"github.com/joho/godotenv"
	"time"
)

type Config struct {
	RPCAddress string `env:"RPC_ADDRESS"`
	RPCPort    uint   `env:"RPC_PORT"`

	MonitorInterval time.Duration `env:"MONITOR_INTERVAL"`
}

func Load() (Config, error) {
	// In case .env file is not found, just ignore the error
	_ = godotenv.Load()

	cfg := Config{}
	if err := env.Parse(&cfg); err != nil {
		return cfg, err
	}
	return cfg, nil
}
