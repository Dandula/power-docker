ARG NODE_VER=lts

FROM node:${NODE_VER}

LABEL maintainer="Vladyslav Revenko <dandular@gmail.com>"

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN usermod -u 999 node \
    && groupmod -g 999 node \
    && apt-get update \
    && apt-get install -y sudo \
    && adduser -u ${USER_ID} --disabled-password --gecos '' docker \
    && groupmod -g ${GROUP_ID} docker \
    && adduser docker sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER "${USER_ID}:${GROUP_ID}"

RUN sudo npm install pm2@latest -g \
    && sudo apt-get clean \
    && sudo rm -r /var/lib/apt/lists/*

CMD ["pm2-runtime", "start", "/etc/pm2/ecosystem.config.js"]