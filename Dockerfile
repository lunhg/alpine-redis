FROM redelivre/alpine:latest

# Arguments
ARG username
ARG pwd
ARG release
ARG protectedMode
ARG redisPort
ARG tcpBacklog
ARG tcpKeepalive
ARG timeout
ARG loglevel
ARG syslogEnabled
ARG syslogIdent
ARG databases
ARG alwaysShowLogo
ARG rdbCompression
ARG rdbChecksum

# Download and configure
WORKDIR /tmp
RUN curl -O $(echo "http://download.redis.io/redis-$release.tar.gz")  \
    && tar xzvf $(echo "redis-$release.tar.gz") \
    && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

# Install
WORKDIR /tmp/redis-$release
RUN make distclean \
    && make \
    && make install \
    && rm -r /tmp/**

# Redis configuration
WORKDIR /
ENV __redis__ /home/$username/.redis
ENV __config__ $__redis__/redis.conf
ENV __log__ /var/log
ENV __run__  /var/run
ENV __logfile__ $__log__/redis.log
ENV __sock__ $__run__/redis.sock
ENV __pid__ $__run__/redis.pid
ENV __data__ $__redis__/data
COPY . $__redis__
RUN mkdir $__data__ \
    && chown -R $username:wheel $__redis__

RUN for i in 's|\$host|127.0.0.1|g' \
             's|\$protected_mode|'$protectedMode'|g' \
             's|\$redis_port|'$redisPort'|g' \
             's|\$timeout|'$timeout'|g' \
             's|\$tcp_backlog|'$tcpBacklog'|g' \
             's|\$tcp_keepalive|'$tcpKeepalive'|g' \
             's|\$loglevel|'$loglevel'|g' \
             's|\$syslogEnabled|'$syslogEnabled'|g' \
             's|\$syslogIdent|'$syslogIdent'|g' \
             's|\$databases|'$databases'|g' \
             's|\$alwaysShowLogo|'$alwaysShowLogo'|g' \
             's|\$rdbCompression|'$rdbCompression'|g' \
             's|\$rdbChecksum|'$rdbChecksum'|g' \
             's|\$rdbDir|'$__data__'|g' \
             's|\$unixsocket|'$__run__/redis.sock'|g' \
             's|\$pidfile|'$__run__/redis.pid'|g' \ 
             's|\$logfile|'$__log__/redis.log'|g' \
             's|\$daemonize|yes|g' \
             's|\$supervised|no|g'  ; do \         
      sed -i $(echo "$i") $__config__; \
    done
RUN echo "$username:$pwd" | sudo chpasswd --md5
EXPOSE $redis_port
CMD echo "$pwd" | sudo redis-server $__config__ 