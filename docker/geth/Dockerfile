FROM ethereum/client-go:v1.13.3

RUN addgroup -g 65000 geth && \
    adduser -u 65000 -G geth -H -D -s /sbin/nologin geth

WORKDIR /node
ADD docker/geth/config.toml .

USER geth
# Note: Apparently metrics have to specified as command line flags, as they are not working from the config file
ENTRYPOINT ["geth", "--config", "config.toml", "--metrics", "--metrics.addr", "0.0.0.0", "--metrics.port", "6060"]