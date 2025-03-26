FROM nginx:alpine

# Backup Nginx default conf
RUN cp /etc/nginx/nginx.conf /etc/nginx/bkp-nginx.conf

# Copier le script qui génère la configuration Nginx
COPY generate_nginx_conf.sh /usr/local/bin/generate_nginx_conf.sh
RUN chmod +x /usr/local/bin/generate_nginx_conf.sh

# Copier le script d'entrée personnalisé
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copier le script d'entrée personnalisé
COPY wait_and_start.sh /usr/local/bin/wait_and_start.sh
RUN chmod +x /usr/local/bin/wait_and_start.sh

# Write new conf for Nginx
COPY ./conf.d/nginx.conf /etc/nginx/nginx.conf

WORKDIR /srv/api/public

RUN apk add --no-cache \
		nss-tools \
        curl \
        bash \
        docker-cli \
	;

RUN curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"; \
    chmod +x mkcert-v*-linux-amd64; \
    cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert; \
    mkdir -p /certs; \
    cd /certs; \
    mkcert -install; \
    mkcert -cert-file localhost.pem -key-file localhost.key.pem localhost  127.0.0.1 ::1 mercure *.local.consoneo.com *.adminoblige.fr *.module.fr local.storageservice.fr; \
	cp "$(mkcert -CAROOT)/rootCA.pem" /certs/localCA.crt; \
    mkdir -p /etc/nginx/ssl; \
    cp /certs/* /etc/nginx/ssl/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh", "-c", "/wait_and_start.sh"]