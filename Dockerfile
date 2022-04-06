FROM alpine:3.14

ENV NGROK_HOME="/ngrok"
ENV NGROK_DOMAIN="ngrok.chaobei.xyz"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache openssl
RUN apk add make

RUN make -v

WORKDIR ${NGROK_HOME}

RUN wget https://golang.google.cn/dl/go1.8.linux-amd64.tar.gz
RUN tar -C /usr/local/ -zxf go1.8.linux-amd64.tar.gz
RUN rm -rf go1.8.linux-amd64.tar.gz

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin"
RUN mkdir /lib64
RUN ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

RUN openssl genrsa -out rootCA.key 2048
RUN openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
RUN openssl genrsa -out device.key 2048
RUN openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -out device.csr
RUN openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000

COPY . .
RUN cp rootCA.pem assets/client/tls/ngrokroot.crt
RUN cp device.key assets/server/tls/snakeoil.key
RUN cp device.crt assets/server/tls/snakeoil.crt

RUN make release-server
RUN make release-client

VOLUME $NGROK_HOME

CMD "top"
