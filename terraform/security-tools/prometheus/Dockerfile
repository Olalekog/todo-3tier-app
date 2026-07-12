FROM prom/prometheus:v2.55.1

COPY prometheus.yml /etc/prometheus/prometheus.yml

EXPOSE 9090

USER 65534:65534

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:9090/-/healthy || exit 1

CMD [ \
  "--config.file=/etc/prometheus/prometheus.yml", \
  "--storage.tsdb.path=/prometheus", \
  "--web.console.libraries=/usr/share/prometheus/console_libraries", \
  "--web.console.templates=/usr/share/prometheus/consoles" \
]
