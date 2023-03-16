FROM openresty/openresty:1.21.4.1-buster-fat

USER root

RUN apt update \
 && apt install supervisor cron unzip --no-install-recommends -y \
 && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* \
 && mkdir /cache \
 && groupadd -g 110 nginx \
 && useradd -u 110 -M -d /cache -s /sbin/nologin -g nginx nginx \
 && curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
 && unzip awscliv2.zip \
 && ./aws/install \
 && rm -rf aws awscliv2.zip

COPY files/startup.sh files/renew_token.sh files/health-check.sh  /
COPY files/ecr.conf /etc/supervisor/conf.d/ecr.conf
COPY files/root /etc/cron.d/root
RUN chmod 0644 /etc/cron.d/root

COPY files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY files/ssl.conf /usr/local/openresty/nginx/conf/ssl.conf

ENV PORT 5000
RUN chmod a+x /startup.sh /renew_token.sh

HEALTHCHECK --interval=5s --timeout=5s --retries=3 CMD /health-check.sh

ENTRYPOINT ["/startup.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
