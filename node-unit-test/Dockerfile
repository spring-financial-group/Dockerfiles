FROM jx3mqubebuild.azurecr.io/docker-io/library/node:23.6

RUN npm install -g @angular/cli@20.3
RUN npm install -g @angular/compiler-cli@20.3
RUN npm install -g typescript@5.8
RUN apt-get update && apt-get install -y libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2

CMD ["bash"]
