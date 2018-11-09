FROM openjdk:8-jdk
LABEL maintainer="Igor Kolomiyets <igor.kolomiyets@iktech.io>"

RUN apt-get install curl  \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install nodejs

ENV SONARQUBE_SCANNER_VERSION 3.2.0.1227

RUN cd /opt; wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip; unzip sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip; rm sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip; ln -s sonar-scanner-${SONARQUBE_SCANNER_VERSION}-linux sonar-scanner
RUN mkdir -p /opt/sonar-scanner/conf
ADD sonar-scanner.properties /opt/sonar-scanner/conf

VOLUME /opt/sonar-scanner/conf

