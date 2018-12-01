FROM jangrewe/gitlab-ci-android
RUN apt-get update -y && apt-get install -y \
    ruby-dev \
    make \
    gcc \
    g++
RUN gem install fastlane -NV
