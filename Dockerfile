# Dockerfile for integration apizombies

FROM ubuntu:14.04
MAINTAINER Oriol Martí <oriol@3scale.net>

RUN apt-get update && apt-get -y install ruby
RUN gem install -N bundler
RUN bundle install
RUN mkdir -p /var/lib/integration

ADD . /var/lib/integration

EXPOSE 80
CMD cd /var/lib/integration && bundle exec ruby /var/lib/integration/main.rb
