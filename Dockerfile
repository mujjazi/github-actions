FROM alpine:latest

RUN	apk add --no-cache \
	bash \
	curl \
	git \
	jq

COPY entrypoint.sh /usr/bin/entrypoint.sh

WORKDIR /home
CMD ["entrypoint.sh"]