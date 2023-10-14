package util

import (
	"log/slog"
	"os"
)

func Fatal(message string, err error, args ...any) {
	args = append(args, "err")
	args = append(args, err)
	slog.Error(message, args...)
	os.Exit(1)
}
