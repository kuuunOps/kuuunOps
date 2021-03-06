FROM java:8-jdk-alpine
LABEL maintainer Kuuun
ENV JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF8 -Duser.timezone=GMT+08"
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add -U tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
COPY hello.jar /
EXPOSE 8888
CMD ["/bin/sh", "-c", "java -jar $JAVA_OPTS /hello.jar"]