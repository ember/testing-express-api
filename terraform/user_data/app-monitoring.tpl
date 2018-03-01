#cloud-config
repo_update: true
repo_upgrade: all

packages:
  - git-core

write_files:
  - content: |
      global:
        scrape_interval:     15s
        evaluation_interval: 15s

        # Attach these labels to any time series or alerts when communicating with
        # external systems (federation, remote storage, Alertmanager).
        external_labels:
            monitor: 'docker-host-alpha'

      # Load and evaluate rules in this file every 'evaluation_interval' seconds.
      rule_files:
        - "alert.rules"

      # A scrape configuration containing exactly one endpoint to scrape.
      scrape_configs:
        - job_name: ec2_instances
          ec2_sd_configs:
            - region: ${aws_region}
              access_key: ${prom_access_key}
              secret_key: ${prom_access_secret}
              port: 9100
          relabel_configs:
              # Use the instance tag as the instance label
            - source_labels: [__meta_ec2_tag_Name]
              target_label: instance

        - job_name: ec2_containers
          ec2_sd_configs:
            - region: ${aws_region}
              access_key: ${prom_access_key}
              secret_key: ${prom_access_secret}
              port: 8080

      alerting:
        alertmanagers:
        - scheme: http
          static_configs:
          - targets:
            - 'alertmanager:9093'
    path: /tmp/prometheus.yml

runcmd:
 - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
 - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
 - apt-get update
 - apt-get -y install docker-ce
 - usermod -aG docker ubuntu
 - curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
 - chmod +x /usr/local/bin/docker-compose
 - systemctl start docker
 - mkdir /app
 - chown ubuntu /app
 - git clone https://github.com/stefanprodan/dockprom /app
 - mv /tmp/prometheus.yml /app/prometheus/prometheus.yml
 - su -l ubuntu -c "cd /app && docker-compose up -d"
