FROM openjdk:8-jdk
LABEL maintainer="Igor Kolomiyets <igor.kolomiyets@iktech.io>"

ARG SONARQUBE_SCANNER_VERSION

RUN cd /opt; wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip; unzip sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip; rm sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip; ln -s sonar-scanner-${SONARQUBE_SCANNER_VERSION}-linux sonar-scanner
RUN mkdir -p /opt/sonar-scanner/conf
ADD sonar-scanner.properties /opt/sonar-scanner/conf

VOLUME /opt/sonar-scanner/conf

