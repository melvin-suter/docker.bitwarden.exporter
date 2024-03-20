FROM node:20-slim

ENV EXPORT_DIR=/data
ENV BITWARDEN_URL=https://vault.example.com
ENV BITWARDEN_USER=user@example.com
ENV BITWARDEN_PASSWORD=YOURBITWARDENPWHERE
ENV EXPORT_ENCRYPTION_PASSWORD=SOMEENCRYPTIONPASSWORD

RUN npm install -g @bitwarden/cli
RUN apt-get update && \
    apt-get install -y jq wget xz-utils unoconv zip enscript 
RUN mkdir /app

RUN wget https://github.com/pdfcpu/pdfcpu/releases/download/v0.6.0/pdfcpu_0.6.0_Linux_x86_64.tar.xz && \
    tar -xf pdfcpu_0.6.0_Linux_x86_64.tar.xz && \
    mv pdfcpu_0.6.0_Linux_x86_64/pdfcpu /usr/local/bin/


WORKDIR /app
COPY src/* /app/
RUN chmod +x /app/export.sh

VOLUME /etc/ssl/certs/ca-bundle.crt

ENTRYPOINT ["/app/export.sh"]
