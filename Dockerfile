FROM ubuntu:12.04

MAINTAINER ek "417@gmail.com"

RUN apt-get update --fix-missing -y
RUN apt-get install -y wget openssh-server net-tools unzip aria2 sudo vim
RUN apt-get install -y --no-install-recommends x11vnc xvfb libncurses5:i386 libstdc++6:i386 openjdk-7-jdk ia32-libs ia32-libs-multiarch git ssh

# Main Android SDK
RUN cd /opt && aria2c -q http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz && aria2c https://dl-ssl.google.com/android/repository/sysimg_armv7a-17_r02.zip
RUN cd /opt && tar xzf android-sdk_r23.0.2-linux.tgz
RUN cd /opt && rm -f android-sdk_r23.0.2-linux.tgz

# Other tools and resources of Android SDK
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
ENV HOME /root


RUN echo y | android update sdk -a -u -f -t tools
RUN echo y | android update sdk -a -u -f -t platform-tools
RUN echo y | android update sdk -a -u -f -t build-tools-20.0.0
RUN echo y | android update sdk -a -u -f -t android-19
RUN echo y | android update sdk -a -u -f -t android-18
RUN echo y | android update sdk -a -u -f -t android-17
RUN echo y | android update sdk -a -u -f -t addon-google_apis-google-19
RUN echo y | android update sdk -a -u -f -t addon-google_apis-google-18
RUN echo y | android update sdk -a -u -f -t addon-google_apis-google-17
RUN echo y | android update sdk -a -u -f -t extra-google-m2repository
RUN echo y | android update sdk -a -u -f -t extra-android-m2repository
RUN cd /opt && unzip sysimg_armv7a-17_r02.zip && mv armeabi-v7a/kernel-qemu ${ANDROID_HOME}/add-ons/addon-google_apis-google-17/images/armeabi-v7a/ && rm -rf armeabi-v7a
ADD noVNC /noVNC/
ADD run.sh /
RUN chmod 755 /run.sh
EXPOSE 6080
EXPOSE 6001
EXPOSE 5900
EXPOSE 22
WORKDIR /
ENTRYPOINT ["/run.sh"]
