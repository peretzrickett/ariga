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

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    docker.io \
    supervisor \
    nano \
    curl \
    git \
    sudo \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3.9 \
    python3.9-dev \
    python3.9-venv \
    python3.9-distutils \
    python3-pip \
    && apt-get clean

# Update the alternatives system to point to Python 3.9 as the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Fix potential issue if symbolic link already exists
RUN [ -L /usr/bin/python ] || ln -s /usr/bin/python3 /usr/bin/python

# Upgrade pip and install requirements
RUN python3 -m pip install --upgrade pip
COPY requirements.txt .
RUN pip3 install --upgrade pip && pip3 install -r requirements.txt

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
stderr_logfile=/var/log/github-runner_stderr.log\n" > /etc/supervisor/supervisord.conf

# Set entrypoint
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
