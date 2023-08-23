FROM debian:12-slim as builder

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
    && make LDFLAGS="--static" nsenter

# Final image
FROM scratch

COPY --from=builder /code/util-linux/nsenter /

ENTRYPOINT ["/nsenter"]
