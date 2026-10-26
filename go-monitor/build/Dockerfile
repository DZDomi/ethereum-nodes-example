FROM golang:1.21.0-alpine3.18 as builder

RUN addgroup -g 65000 -S monitor && \
    adduser -u 65000 -G monitor -S -H -D monitor

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o monitor cmd/monitor/main.go

FROM scratch

COPY --from=builder /etc/passwd /etc/passwd

WORKDIR /app
COPY --from=builder --chown=monitor:monitor /build/monitor .

USER monitor
ENTRYPOINT ["./monitor"]