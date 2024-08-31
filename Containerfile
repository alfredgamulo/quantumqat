ARG SOURCE_IMAGE="bazzite"
ARG SOURCE_SUFFIX=""
ARG SOURCE_TAG="stable"

FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}

COPY system_files /
COPY scripts /scripts

RUN /scripts/00_prepare.sh && \
    /scripts/10_build.sh && \
    /scripts/20_install.sh && \
    /scripts/30_configure.sh && \
    ostree container commit
