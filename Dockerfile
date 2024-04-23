FROM golang:1.20 as builder

ENV TAG="nightly"
ENV COMMIT=""

WORKDIR /build

COPY . .

RUN make build

# Download youtube-dl
RUN wget -O /usr/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp && \
    chmod +x /usr/bin/yt-dlp

FROM opensuse/tumbleweed:latest

WORKDIR /app

RUN zypper in ca-certificates-cacert python3 python3-pip ffmpeg python3-tzdata \
    # https://github.com/golang/go/issues/59305
    glibc-devel && ln -s /usr/lib64/libc.so /usr/lib/libresolv.so.2 \
    && zypper clean

COPY --from=builder /usr/bin/yt-dlp /usr/bin/youtube-dl
COPY --from=builder /build/bin/podsync /app/podsync

ENTRYPOINT ["/app/podsync"]
CMD ["--no-banner"]
