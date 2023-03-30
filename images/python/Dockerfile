ARG PYTHON_VER=latest

FROM python:${PYTHON_VER}

LABEL maintainer="Vladyslav Revenko <dandular@gmail.com>"

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apt-get update \
    && apt-get install -y sudo \
    && adduser -u ${USER_ID} --disabled-password --gecos '' docker \
    && groupmod -g ${GROUP_ID} docker \
    && adduser docker sudo \
    && echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER "${USER_ID}:${GROUP_ID}"

ENV PATH /home/docker/.local/bin:$PATH

RUN pip install poetry \
    && sudo apt-get clean \
    && sudo rm -r /var/lib/apt/lists/*