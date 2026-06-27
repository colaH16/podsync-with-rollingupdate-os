ARG PODSYNC_VERSION
ARG DENO_VERSION

FROM ghcr.io/mxpv/podsync:${PODSYNC_VERSION} AS podsync
FROM ghcr.io/denoland/deno:bin-${DENO_VERSION} AS deno

FROM opensuse/tumbleweed


RUN sed -i -E '/^baseurl=.*download.opensuse.org/ s|$|?REGION=EU\&AVOID_COUNTRY=CN,RU,BY|' /etc/zypp/repos.d/*.repo \
 && printf '%s\n' \
      'download.connect_timeout = 3' \
      'download.transfer_timeout = 900' \
      'download.max_silent_tries = 1' \
      >> /etc/zypp/zypp.conf \
 && grep -R '^baseurl=' /etc/zypp/repos.d \
 && zypper -n refresh \
 && zypper -n install --no-recommends ca-certificates python313 python313-pip \
      ffmpeg-7 timezone nodejs24 \
 && ln -sf /usr/bin/python3.13 /usr/local/bin/python3 \
 && ln -sf /usr/bin/pip3.13 /usr/local/bin/pip3 \
 && zypper clean -a

WORKDIR /app

COPY --from=deno /deno /usr/local/bin/deno
COPY --from=podsync /usr/local/bin/youtube-dl /usr/local/bin/youtube-dl
COPY --from=podsync /usr/local/bin/youtube-dl /usr/bin/yt-dlp
COPY --from=podsync /usr/local/bin/youtube-dl /usr/local/bin/yt-dlp
COPY --from=podsync /app/podsync /app/podsync

RUN deno --version && node --version && python3 --version

ENTRYPOINT ["/app/podsync"]
CMD ["--no-banner"]