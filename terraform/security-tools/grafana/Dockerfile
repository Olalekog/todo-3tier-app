FROM grafana/grafana-oss:11.4.0

COPY provisioning /etc/grafana/provisioning

EXPOSE 3000

USER 472:472

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:3000/api/health || exit 1
