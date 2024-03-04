from debian:12-slim as base

FROM base as builder

# intall gcc and supporting packages
RUN apt-get update          \
    && apt-get install -yq  \
        make                \
        gcc                 \
        gettext             \
        autopoint           \
        bison               \
        libtool             \
        automake            \
        pkg-config          \
        flex                \
        libsqlite3-dev      \
    && rm -rf /var/lib/apt

WORKDIR /code

# download util-linux sources
ARG UTIL_LINUX_VER
ADD https://github.com/util-linux/util-linux/archive/v${UTIL_LINUX_VER}.tar.gz .
RUN tar -xf v${UTIL_LINUX_VER}.tar.gz && mv util-linux-${UTIL_LINUX_VER} util-linux

# make static version
WORKDIR /code/util-linux
RUN ./autogen.sh    \
    && ./configure  \
    && make LDFLAGS="--static" -j2 nsenter

# Final image
FROM base

COPY --from=builder /code/util-linux/nsenter /

COPY find-big-containers.sh /usr/local/bin/find-big-containers.sh
run chmod +x /usr/local/bin/find-big-containers.sh

CMD ["/nsenter"]
