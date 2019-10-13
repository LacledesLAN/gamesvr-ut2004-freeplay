# escape=`
FROM lacledeslan/gamesvr-ut2004

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

LABEL maintainer="Laclede's LAN <contact @lacledeslan.com>" `
      com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Laclede's LAN" `
      org.label-schema.description="Unreal Tournament 2004 Dedicated Freeplay Server" `
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-ut2004-freeplay"

COPY --chown=UT2004:root ./dist /app

RUN usermod -l UT2004-Freeplay UT2004

USER UT2004-Freeplay

ONBUILD USER root
