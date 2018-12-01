FROM jangrewe/gitlab-ci-android
MAINTAINER Artem Torubarov <torubarov-a-a@yandex.ru>
RUN apt-get update -y && apt-get install -y \
    ruby-dev \
    make \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN gem install fastlane -NV
RUN apt-get clean
