FROM alpine:3.14

ARG NGROK_DOMAIN
ENV NGROK_HOME="/ngrok"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache openssl
RUN apk add make

RUN make -v

WORKDIR ${NGROK_HOME}
COPY . .

RUN wget https://golang.google.cn/dl/go1.8.linux-amd64.tar.gz
RUN tar -C /usr/local/ -zxf go1.8.linux-amd64.tar.gz
RUN rm -rf go1.8.linux-amd64.tar.gz

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin"
RUN mkdir /lib64
RUN ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

VOLUME $NGROK_HOME

ENTRYPOINT ["./build.sh"]
