# Ansible Prometheus docker role

`prometheus` is an [ansible](http://www.ansible.com) role which:

 * installs and configures prometheus in a docker container
 * installs and configures alertmanager in a docker container
 * install and configures blackbox_exporter in a docker container
 * optionally install node_exporter in a docker container

## Prerequisites

This role requires a host with docker-engine installed. 

* [AWS amis](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html)
* Vagrant
  - [CentOS 7](https://atlas.hashicorp.com/dockpack/boxes/centos7)
  - [Ubuntu 12.04](https://vagrantcloud.com/williamyeh/boxes/ubuntu-trusty64-docker)

## Installation

Using `ansible-galaxy`:

```
$ ansible-galaxy install mkrakowitzer.prometheus
```

Using `git`:

```
$ git clone https://github.com/mkrakowitzer/ansible-prometheus.git
```

These files will be created on your host:

* alert.rules
* alertmanager.yml 
* prometheus.yml
* blackbox_exporter.yml

## Variables

See default variables and there values in `defaults/main.yml`.

## Handlers

These are the handlers that are defined in `handlers/main.yml`.

* `reload prometheus`
* `reload alertmanager`
* `reload blackbox_exporter`
* `reload node_exporter`

## Example playbook that configures prometheus

```yml
---
- hosts: all
  roles:
    - ansible-prometheus
  vars:
    install_prometheus: true
    install_alertmanager: true
    install_blackbox_exporter: true
    install_node_exporter: true
    alertmanager_ip: "{{ ansible_eth1.ipv4.address }}"
    # prometheus.yml
    prometheus_external_labels:
      datacenter: pdc
    prometheus_rule_files:
      - '/prometheus-data/alert.rules'
      - '/prometheus-data/my_custom_rules.rules'
    prometheus_scrape_configs:
    - job_name: 'prometheus'
      scrape_interval: 10s
      scrape_timeout:  10s
      static_configs:
        - targets: ['localhost:9090']
    - job_name: 'node_exporter'
      scrape_interval: 5s
      static_configs:
        - targets:
          - "{{ ansible_eth1.ipv4.address }}:9100"
    - job_name: 'blackbox'
      metrics_path: /probe
      params:
        module: [http_2xx]
      static_configs:
        - targets:
          - "{{ ansible_eth1.ipv4.address }}:9090"
      relabel_configs:
        - source_labels: [__address__]
          regex: (.*)(:9090)?
          target_label: __param_target
          replacement: ${1}
        - source_labels: [__param_target]
          regex: (.*)
          target_label: instance
          replacement: ${1}
        - source_labels: []
          regex: .*
          target_label: __address__
          replacement: "{{ ansible_eth1.ipv4.address }}:9115"  # Blackbox exporter.
    # alertmanager.yml
    alertmanager_route:
      group_by: ['cluster','alertname','host']
      group_wait: 30s
      group_interval: 2m
      repeat_interval: 10m
      receiver: slack_general
      routes:
        - match:
            severity: warning
          receiver: slack_general
        - match:
              severity: critical
          receiver: slack_general
          continue: true
        - match:
              severity: critical
          receiver: pagerduty_uk
          continue: true
    alertmanager_receivers:
    - name: slack_general
      slack_configs:
      - send_resolved: true
        api_url: 'https://hooks.slack.com/services/XXX/XXXXX/XXXXXXXXXXX'
        channel: '#alerts'
    - name: pagerduty_uk
      pagerduty_configs:
      - service_key: XXXXXXXXXXXXXXX
        send_resolved: true
```

## Testing

### TestKitchen tests

```
$ bundle install
$ bundle exec kitchen test
```

### Manual testing
```
$ git clone https://github.com/krakowitzerm/ansible-prometheus.git
$ cd ansible-prometheus
$ ansible-galaxy install --role-file=requirements.yml --roles-path=roles --force
$ vagrant up
$ vagrant ssh
```
Test away

## Contributing
Take care to maintain the existing coding style. Add unit tests and examples for any new or changed functionality.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
MIT
