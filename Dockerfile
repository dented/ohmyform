FROM  node:10-alpine
LABEL maintainer="Gram <g@whub.io>"

# Create a group and a user with name "ohmyform".
RUN addgroup --gid 9999 ohmyform && adduser -D --uid 9999 -G ohmyform ohmyform

# Install some needed packages
RUN apk add --no-cache git=2.20.1-r0 python=2.7.16-r1 \
	&& rm -rf /tmp/* \
	&& npm install --quiet -g grunt@1.0.4 bower@1.8.8 pm2@3.5.1 \
	&& npm cache clean --force \
	&& mkdir -p /opt/app/public/lib

# to expose the public folder to other containers
# VOLUME /opt/app

WORKDIR /opt/app

## TODO: Find a method that's better than this for passing ENV's if possible.
# Set default ENV
ENV NODE_ENV=development \
    SECRET_KEY=9deff3f0976447ddd3da68fed54b87ab54c6c114568685c4c15cd316555669200dec2fa1c5188560da9441981ffd62ee29c7e27e7caf2b118f57c47e4316a110 \
    PORT=5000 \
    BASE_URL=localhost \
    SOCKET_PORT=20523 \
    SIGNUP_DISABLED=FALSE \
    SUBDOMAINS_DISABLED=TRUE \
    ENABLE_CLUSTER_MODE=FALSE \
    MAILER_EMAIL_ID=ohmyform@localhost \
    MAILER_PASSWORD="" \
    MAILER_FROM=ohmyform@localhost \
    MAILER_SERVICE_PROVIDER="" \
    MAILER_SMTP_HOST="" \
    MAILER_SMTP_PORT="" \
    MAILER_SMTP_SECURE="" \
    CREATE_ADMIN=FALSE \
    ADMIN_EMAIL=admin@ohmyform.com \
    ADMIN_USERNAME=root \
    ADMIN_PASSWORD=root \
    APP_NAME=OhMyForm \
    APP_KEYWORDS="" \
    APP_DESC="" \
    COVERALLS_REPO_TOKEN="" \
    GOOGLE_ANALYTICS_ID="" \
    RAVEN_DSN=""

# keep .dockerignore up to date
COPY . .

RUN npm install --only=production \
    && bower install --allow-root -f \
    && grunt build

# Change to non-root privilege
USER ohmyform

# Run OhMyForm server
CMD ["node", "server.js"]
