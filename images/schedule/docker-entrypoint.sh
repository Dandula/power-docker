#!/bin/bash

# setup for sendmail
if dpkg -s sendmail &> /dev/null; then
  IP_ADDR=$(hostname -i)
  HOSTNAME=$(hostname)
  printf '%s\t%s %s.localhost' "$IP_ADDR" "$HOSTNAME" "$HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
  sudo service sendmail restart
fi

# based on https://habr.com/ru/company/redmadrobot/blog/305364/

# create log file if not exists
sudo touch /var/log/cron/cron.log
sudo chmod 0666 /var/log/cron/cron.log

# get new cron jobs
sudo find /etc/cron.d -type f ! -name '.placeholder' -delete
sudo cp -a /home/docker/jobs/. /etc/cron.d

# set root:root owner (required by cron)
sudo chown -R root:root /etc/cron.d

# remove write permission for (g)roup and (o)ther (required by cron)
sudo chmod -R go-w /etc/cron.d

# update default values of PAM environment variables (used by CRON scripts)
env | while read -r LINE; do  # read STDIN by line
  # split LINE by "="
  IFS="=" read -r VAR VAL <<< "${LINE}"
  # remove existing definition of environment variable, ignoring exit code
  sudo sed --in-place "/^${VAR}[[:blank:]=]/d" /etc/security/pam_env.conf || true
  # append new default value of environment variable
  echo "${VAR} DEFAULT=\"${VAL}\"" | sudo tee -a /etc/security/pam_env.conf > /dev/null
done

case "$PM_UTILITY" in
  pm2)
    pm2 start --no-daemon "/etc/pm2/ecosystem.config.js" && \
      pm2 save --force
    ;;
  supervisor|*)
    sudo supervisord -c "/etc/supervisor/conf.d/supervisord.conf"
    ;;
esac