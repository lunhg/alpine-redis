FROM redelivre/alpine:latest
ARG username
ARG release
WORKDIR /tmp
RUN curl -O $(echo "http://download.redis.io/redis-$release.tar.gz")  \
    && tar xzvf $(echo "redis-$release.tar.gz")
WORKDIR /tmp/redis-$release
RUN make distclean
RUN make
RUN make install
RUN mkdir /etc/redis
COPY ./redis.conf /etc/redis/redis.conf
USER $username
EXPOSE 6379
ENTRYPOINT sudo redis-server
