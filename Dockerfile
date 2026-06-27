FROM ghcr.io/mxpv/podsync:v2.8.0 AS podsync

FROM opensuse/tumbleweed

RUN zypper -n refresh \
 && zypper -n install --no-recommends ca-certificates python3 python3-pip \
      ffmpeg  timezone  nodejs deno && zypper clean -a

WORKDIR /app

RUN chmod 777 /usr/local/bin
COPY --from=podsync /usr/local/bin/youtube-dl /usr/local/bin/youtube-dl
COPY --from=podsync /usr/local/bin/youtube-dl /usr/bin/yt-dlp
COPY --from=podsync /usr/local/bin/youtube-dl /usr/local/bin/yt-dlp
COPY --from=podsync /app/podsync /app/podsync

ENTRYPOINT ["/app/podsync"]
CMD ["--no-banner"]