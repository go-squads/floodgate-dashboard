FROM ruby:2.5.1-alpine

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                nodejs \
                                tzdata \
                                sqlite-dev

ENV APP_PATH /usr/src/app

RUN gem install bundler
# Different layer for gems installation
WORKDIR $APP_PATH
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH
RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

# Copy the application into the container
COPY . $APP_PATH
EXPOSE 3000
CMD bundle install && rails s
