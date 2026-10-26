# Note: I would have prefered an alpine image here, but since the
# prysm developers link it to glib, it wont start on alpine
FROM ubuntu:jammy

ARG PRYSM_VERSION=4.0.8

RUN apt update && \
    apt install -y --no-install-recommends ca-certificates wget curl

RUN wget -O beacon-chain \
    "https://github.com/prysmaticlabs/prysm/releases/download/v4.0.8/beacon-chain-v${PRYSM_VERSION}-linux-arm64" && \
    chmod +x beacon-chain && \
    mv beacon-chain /usr/bin

RUN groupadd -g 65000 prysm && \
    useradd -u 65000 -g prysm -l -M -s /usr/sbin/nologin -d /nonexistent prysm

WORKDIR /node
RUN chown -R prysm:prysm /node

ADD docker/prysm/config.yaml .
ADD docker/prysm/entrypoint.sh /usr/local/bin/entrypoint

USER prysm
ENTRYPOINT ["entrypoint"]