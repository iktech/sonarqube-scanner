FROM eclipse-temurin:17.0.6_10-jre
LABEL maintainer="Igor Kolomiyets <igor.kolomiyets@iktech.io>"

RUN apt-get update -y
RUN apt-get install curl zip -y
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install nodejs

ARG SONARQUBE_SCANNER_VERSION=4.5.0.2216

WORKDIR /opt
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip
RUN unzip sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip
RUN pwd
RUN ls -l /opt
RUN rm sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip
RUN ln -s sonar-scanner-${SONARQUBE_SCANNER_VERSION}-linux sonar-scanner
RUN ls -l /opt
RUN mkdir -p /opt/sonar-scanner/conf
ADD sonar-scanner.properties /opt/sonar-scanner/conf

VOLUME /opt/sonar-scanner/conf

