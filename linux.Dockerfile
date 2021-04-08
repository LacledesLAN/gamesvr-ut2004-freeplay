# escape=`
ARG CONTAINER_REGISTRY="docker.io"

FROM $CONTAINER_REGISTRY/lacledeslan/gamesvr-ut2004:latest

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

LABEL com.lacledeslan.build-node=$BUILDNODE `
        org.opencontainers.image.source="https://github.com/lacledeslan/gamesvr-ut2004-freeplay" `
        org.opencontainers.image.title="Laclede's LAN Unreal Tournament 2004 Dedicated Freeplay Server" `
        org.opencontainers.image.url=https://github.com/LacledesLAN/README.1ST `
        org.opencontainers.image.vendor="Laclede's LAN" `
        org.opencontainers.image.version=$SOURCE_COMMIT

COPY --chown=UT2004:root ./dist /app

RUN usermod -l UT2004-Freeplay UT2004

COPY --chown=UT2004-Freeplay:root /linux/ll-tests/*.sh /app/ll-tests/

RUN chmod +x /app/ll-tests/*.sh

USER UT2004-Freeplay

ONBUILD USER root
