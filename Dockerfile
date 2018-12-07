FROM jangrewe/gitlab-ci-android
MAINTAINER Artem Torubarov <torubarov-a-a@yandex.ru>
RUN apt-get update -y && apt-get install -y \
    ruby-dev \
    make \
    gcc \
    g++ \
    qemu-kvm  \
    libvirt-bin \
    ubuntu-vm-builder  \
    bridge-utils
RUN gem install fastlane -NV
RUN echo "gem \"fastlane\"" > Gemfile
RUN echo "plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')" >> Gemfile
RUN echo "eval_gemfile(plugins_path) if File.exist?(plugins_path)" >> Gemfile
RUN /sdk/tools/bin/sdkmanager "system-images;android-28;google_apis_playstore;x86"
RUN /sdk/tools/bin/sdkmanager --licenses
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get clean
