ARG SOURCE_IMAGE="bazzite"
ARG SOURCE_SUFFIX=""
ARG SOURCE_TAG="stable"

FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}

ARG IMAGE_NAME="${IMAGE_NAME:-quantumqat}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-alfredgamulo}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-fsync}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files /
COPY scripts /scripts
COPY --from=ghcr.io/blue-build/modules/bling:latest /modules/bling/installers/1password.sh /scripts/1password.sh

RUN /scripts/00_prepare.sh && \
    /scripts/10_customize.sh && \
    /scripts/20_install.sh && \
    /scripts/30_configure.sh && \
    /scripts/90_cleanup.sh && \
    ostree container commit
