FROM bigtruedata/sbt as builder

ENV ZK_HOSTS=localhost:2181 \
     KM_VERSION=2.0.0.2

RUN mkdir -p /tmp && \
    cd /tmp && \
    wget https://github.com/yahoo/kafka-manager/archive/${KM_VERSION}.tar.gz && \
    tar xxf ${KM_VERSION}.tar.gz && \
    cd /tmp/kafka-manager-${KM_VERSION} && \
    sbt clean dist && \
    unzip  -d / ./target/universal/kafka-manager-${KM_VERSION}.zip && \
    rm -fr /tmp/${KM_VERSION} /tmp/kafka-manager-${KM_VERSION}

WORKDIR /kafka-manager-${KM_VERSION}

FROM openjdk:8-jdk-alpine3.9
ENV ZK_HOSTS=localhost:2181 \
     KM_VERSION=2.0.0.2
COPY --from=builder /kafka-manager-${KM_VERSION} /
RUN apk add bash
EXPOSE 9000
ENTRYPOINT ["./bin/kafka-manager","-Dconfig.file=conf/application.conf"]
