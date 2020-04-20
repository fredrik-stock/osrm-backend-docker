FROM peterevans/osrm-backend

LABEL \
  maintainer="Fredrik Stock <fredrik@eltele.no>" \
  org.opencontainers.image.title="osrm-backend" \
  org.opencontainers.image.description="Docker image for the Open Source Routing Machine (OSRM) osrm-backend. Monitors URL for new data" \
  org.opencontainers.image.authors="Peter Evans <mail@peterevans.dev>, Fredrik Stock <fredrik@eltele.no>" \
  org.opencontainers.image.url="https://github.com/fredrik-stock/osrm-backend-docker" \
  org.opencontainers.image.vendor="https://peterevans.dev" \
  org.opencontainers.image.licenses="MIT"

ENV OSRM_VERSION 5.22.0

# Let the container know that there is no TTY
ARG DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get -y update && apt-get install -y -qq --no-install-recommends cron

# Set the entrypoint
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Implementation specific
COPY monitor.sh /
RUN chmod +x /monitor.sh

COPY monitor-cron /etc/cron.d/monitor-cron
RUN chmod 0644 /etc/cron.d/monitor-cron
RUN crontab /etc/cron.d/monitor-cron
CMD cron

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5000
