#cloud-config
repo_update: true
repo_upgrade: all

write_files:
  - content: |
      worker_processes 1;

      events { worker_connections 1024; }

      http {

          sendfile on;

          upstream docker-api {
              server api-app:3000;
          }

          server {
              listen 80;

              location / {
                  proxy_pass         http://docker-api;
                  proxy_redirect     off;
                  proxy_set_header   Host $host;
                  proxy_set_header   X-Real-IP $remote_addr;
                  proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header   X-Forwarded-Host $server_name;
              }
          }
      }
    path: /tmp/nginx.conf
  - content: |
      version: '3'
      services:
        web:
          container_name: nginx-VERSION_HOLDER
          image: nginx
          restart: unless-stopped
          links:
            - api-app
          volumes:
            - ./nginx.conf:/etc/nginx/nginx.conf:ro
          ports:
            - "80:80"
          command: [nginx, '-g', 'daemon off;']

        api-app:
          container_name: api-${api_version}-VERSION_HOLDER
          image: pfragoso/testing-express-api:${api_version}
          restart: unless-stopped

        nodeexporter:
          image: prom/node-exporter:v0.15.0
          container_name: nodeexporter-VERSION_HOLDER
          user: root
          privileged: true
          volumes:
            - /proc:/host/proc:ro
            - /sys:/host/sys:ro
            - /:/rootfs:ro
          command:
            - '--path.procfs=/host/proc'
            - '--path.sysfs=/host/sys'
            - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$$|/)"'
          restart: unless-stopped
          ports:
            - 9100:9100
          network_mode: host

        cadvisor:
          image: google/cadvisor:v0.28.3
          container_name: cadvisor-VERSION_HOLDER
          volumes:
            - /:/rootfs:ro
            - /var/run:/var/run:rw
            - /sys:/sys:ro
            - /var/lib/docker/:/var/lib/docker:ro
            - /cgroup:/cgroup:ro
          restart: unless-stopped
          ports:
            - 8080:8080
          network_mode: host

    path: /tmp/docker-compose.yml
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
 - sed -i "s,VERSION_HOLDER,$(shuf -i 1-100 -n 1),g" /tmp/*.yml
 - mv /tmp/docker-compose.yml /tmp/nginx.conf /app
 - chown ubuntu /app
 - su -l ubuntu -c "cd /app && docker-compose up -d"