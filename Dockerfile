FROM node:12-alpine

# Install build dependancies.
RUN apk --no-cache add git python openssh make g++ iproute2 bash curl

ADD ./.profile.d /app/.profile.d
RUN rm /bin/sh \
  && ln -s /bin/bash /bin/sh \
  && printf '#!/usr/bin/env bash\n\nset +o posix\n\n[ -z "$SSH_CLIENT" ] && source <(curl --fail --retry 7 -sSL "$HEROKU_EXEC_URL")\n' > /app/.profile.d/heroku-exec.sh \
  && chmod +x /app/.profile.d/heroku-exec.sh
# Create app directory.
RUN mkdir -p /usr/src/app/.ssh
WORKDIR /usr/src/app

# Bundle application source.
COPY . /usr/src/app

# Store the current git revision.
ARG REVISION_HASH
RUN mkdir -p dist/core/common/__generated__ && \
  echo "{\"revision\": \"${REVISION_HASH}\"}" > dist/core/common/__generated__/revision.json

# Run all application code and dependancy setup as a non-root user:
# SEE: https://github.com/nodejs/docker-node/blob/a2eb9f80b0fd224503ee2678867096c9e19a51c2/docs/BestPractices.md#non-root-user
RUN chown -R node /usr/src/app
USER node

# RUN which npm
# RUN alias npm='node --max_old_space_size=8000 /usr/bin/npm'
# RUN alias npm

# Setup the environment
ENV LOGGING_LEVEL debug
ENV NODE_ENV production
ENV PORT 5000

# RUN npm install --save https://github.com/coralproject/patched/tarball/react-relay-10.0.1
# RUN npm install --save https://github.com/projectfluent/IntlPluralRules/tarball/master
RUN rm -rf node_modules/*
RUN npm install --save fluent-intl-polyfill
RUN npm install npm-run-all --save-dev

# Install build static assets and clear caches.
RUN npm --production=false install
RUN NODE_ENV=production npm run build

# RUN npm run build
RUN npm prune --production

EXPOSE 5000

# Run the node process directly instead of using `npm run start`:
# SEE: https://github.com/nodejs/docker-node/blob/a2eb9f80b0fd224503ee2678867096c9e19a51c2/docs/BestPractices.md#cmd
CMD ["node", "dist/index.js"]
