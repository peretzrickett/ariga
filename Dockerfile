FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git docker.io supervisor

# Install Atlas
RUN curl -s https://install.ariga.io | sh

# Create Supervisor config directory
RUN mkdir -p /etc/supervisor/conf.d

# Supervisor config for Docker
RUN echo "[program:dockerd]\n\
command=/usr/bin/dockerd\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/dockerd.log\n\
stderr_logfile=/var/log/dockerd_err.log" > /etc/supervisor/conf.d/docker.conf

# Create runner startup script
RUN echo "#!/bin/bash\n\
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf" > /usr/local/bin/start-runner.sh

RUN chmod +x /usr/local/bin/start-runner.sh
