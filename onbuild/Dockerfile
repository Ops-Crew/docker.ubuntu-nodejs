FROM node:6.9.1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ONBUILD ARG NODE_ENV
ONBUILD ENV NODE_ENV $NODE_ENV
ONBUILD COPY package.json /usr/src/app/
ONBUILD COPY bower.json /usr/src/app/
ONBUILD COPY .bowerrc /usr/src/app/
ONBUILD COPY .npmrc /usr/src/app/
ONBUILD COPY .gitignore /usr/src/app/
ONBUILD RUN npm i
ONBUILD COPY . /usr/src/app

CMD ["npm", "start"]
