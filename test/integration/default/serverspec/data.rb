global_contents = 'global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    test: test'

rule_contents = "rule_files: [u'/prometheus-data/alert.rules']"

scrape_configs_contents = 'scrape_configs:
-   job_name: prometheus
    scrape_interval: 10s
    scrape_timeout: 10s
    static_configs:
    -   targets:
        - localhost:9090
-   job_name: node_exporter
    scrape_interval: 5s
    static_configs:
    -   targets:
        - 10.0.2.15:9100'

alertmanager_content = 'route:
    group_by:
    - cluster
    - alertname
    - host
    group_interval: 2m
    group_wait: 30s
    receiver: webhook
    repeat_interval: 10m
    routes:
    -   match:
            severity: warning
        receiver: webhook
    -   match:
            severity: critical
        receiver: webhook
templates:
- /alertmanager/template/*.tmpl

inhibit_rules:
-   equal:
    - alertname
    - host
    source_match:
        severity: critical
    target_match:
        severity: warning

receivers:
-   name: webhook
    webhook_configs:
    -   url: http://127.0.0.1:5001/'
