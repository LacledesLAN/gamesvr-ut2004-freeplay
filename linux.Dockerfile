ARG CONTAINER_REGISTRY="docker.io"

FROM $CONTAINER_REGISTRY/lacledeslan/gamesvr-ut2004:latest

ARG BUILD_NODE=unspecified
ARG GIT_REVISION=unspecified

LABEL architecture="amd64" \
    com.lacledeslan.build-node=$BUILD_NODE \
    maintainer="Laclede's LAN <contact@lacledeslan.com>" \
    org.opencontainers.image.description="Laclede's LAN Unreal Tournament 2004 Dedicated Freeplay Server" \
    org.opencontainers.image.revision=$GIT_REVISION \
    org.opencontainers.image.source="https://github.com/LacledesLAN/gamesvr-ut2004-freeplay" \
    org.opencontainers.image.vendor="Laclede's LAN"

COPY --chown=UT2004:root ./dist /app

RUN usermod -l UT2004-Freeplay UT2004

USER UT2004-Freeplay

ONBUILD USER root
