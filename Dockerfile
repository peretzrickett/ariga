FROM myoung34/github-runner:latest

# Add build argument for the token
ARG RUNNER_TOKEN
ARG REPO_URL
ARG ATLAS_TOKEN

# Create a non-root user (githubrunner)
RUN useradd -m githubrunner && passwd -d githubrunner && usermod -aG sudo githubrunner

# Set permissions for the actions-runner directory
RUN chown -R githubrunner:githubrunner /actions-runner

# Switch to the non-root user and configure the runner
RUN su - githubrunner -c "/actions-runner/config.sh --name my_runner --url $REPO_URL --token $RUNNER_TOKEN --unattended --replace"

# Install Atlas, Docker, Supervisor, etc.
RUN apt-get update && apt-get install -y curl git docker.io supervisor

# Install Atlas
RUN curl -sSf https://atlasgo.sh | sh
RUN atlas login --token $ATLAS_TOKEN

# Supervisor configuration
RUN echo -e "[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
pidfile=/var/run/supervisord.pid\n\
childlogdir=/var/log/supervisor\n\
[program:dockerd]\n\
command=/usr/bin/dockerd\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/dockerd_stdout.log\n\
stderr_logfile=/var/log/dockerd_stderr.log\n\
[program:github-runner]\n\
command=/actions-runner/bin/runsvc.sh\n\
directory=/actions-runner/\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/github-runner_stdout.log\n\
stderr_logfile=/var/log/github-runner_stderr.log" > /etc/supervisor/supervisord.conf

# Set entrypoint
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
