FROM debian:latest

# NOTE: move as much stuff (as possible without it making no sense) before COPY commands

# =Deps=
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "git", "gcc", "g++", "make", "python3-dev", "python3-pip", "python3-venv", "libxml2-dev", "libxslt1-dev", "zlib1g-dev", "gettext", "curl", "libmariadb-dev"]

# ==Node===
RUN ["/bin/sh", "-c", "curl -sL https://deb.nodesource.com/setup_12.x | bash -"]
RUN ["apt-get", "install", "-y", "nodejs"]
# TODO: check if node stuffs are req'd at runtime
RUN ["npm", "install", "-g", "sass", "postcss-cli", "postcss", "autoprefixer"]

# =User=
RUN useradd dmoj && passwd -l dmoj && \
    useradd wlmoj-uwsgi && passwd -l wlmoj-uwsgi

# =Virtualenv=
RUN mkdir /opt/venv && \
    python3 -m venv /opt/venv

# =Site=
# ==Deps==
RUN ["/opt/venv/bin/python3", "-m", "pip", "install", "mysqlclient", "websocket-client", "uwsgi", "redis"]
RUN ["mkdir", "/opt/wlmoj"]
WORKDIR "/opt/wlmoj"
COPY ./requirements.txt /opt/wlmoj/requirements.txt
RUN ["/opt/venv/bin/python3", "-m", "pip", "install", "-r", "requirements.txt"]
# ==Itself==
COPY . /opt/wlmoj
RUN ["git", "submodule", "init"]
RUN ["git", "submodule", "update"]
# ==Cleanup==
RUN ["rm", "-rf", "docker"]
RUN ["rm", "-f", "Dockerfile", "docker-compose.yml"]
# ==Checks and Non-dynamic Setup==
COPY ./docker/wlmoj/local_settings.py /opt/wlmoj/dmoj/local_settings.py
RUN set -eux && \
    /opt/venv/bin/python3 manage.py check && \
    mkdir /opt/wlmoj-static && \
    /opt/venv/bin/python3 manage.py collectstatic --noinput && \
    /opt/wlmoj/make_style.sh && \
    /opt/venv/bin/python3 manage.py compilemessages && \
    /opt/venv/bin/python3 manage.py compilejsi18n

# =Event Server=
WORKDIR "/opt/wlmoj/websocket"
RUN ["npm", "install"]
RUN ["mkdir", "/opt/wlmoj-evsv", "/opt/wlmoj-etc"]
COPY ./docker/evsv/config.js  /opt/wlmoj/websocket/config.js
COPY ./docker/evsv/run.sh     /opt/wlmoj-evsv/run.sh

# =Misc=
WORKDIR "/opt/wlmoj"
COPY ./docker/wlmoj/uwsgi.ini /opt/wlmoj-etc/uwsgi.ini
COPY ./docker/wlmoj/run.sh    /opt/wlmoj-etc/run.sh
COPY ./docker/wlmoj/docker_settings.py /opt/wlmoj/dmoj/docker_settings.py
COPY ./docker/wlmoj/local_settings_error.py /opt/wlmoj/dmoj/local_settings.py

USER root
CMD ["/opt/wlmoj-etc/run.sh"]
