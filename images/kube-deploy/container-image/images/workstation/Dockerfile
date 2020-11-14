FROM buster-qemu

# Set a local password root root
RUN echo "root:root" | chpasswd

RUN apt-get install --yes mate
RUN apt-get install --yes wget git make

ADD xinit.configuration /tmp/xinit.configuration
# Get selections using debconf-get-selections | grep keyboard-configuration | grep d-i
RUN debconf-set-selections < /tmp/xinit.configuration
RUN apt-get install --yes keyboard-configuration

RUN apt-get install --yes xinit
RUN apt-get install --yes chromium
RUN apt-get install --yes xserver-xorg-video-fbdev qemu-guest-agent

RUN cd /tmp && wget -O go.tar.gz https://golang.org/dl/go1.15.4.linux-amd64.tar.gz && sudo tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz
RUN cd /tmp && wget -O vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868 && dpkg -i vscode.deb && rm vscode.deb

RUN apt-get install --yes lightdm

RUN apt-get install --yes dconf-cli

RUN apt-get install --yes htop

# Install bazel
RUN apt install --yes curl gnupg
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/bazel.gpg
RUN echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" > /etc/apt/sources.list.d/bazel.list
RUN apt update
RUN apt install --yes bazel bazel-2.2.0

# Install awscli
#RUN apt install --yes python3 pip
#RUN pip3 install awscli
RUN apt install --yes awscli

# Install kubectl & gcloud sdk
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list
RUN apt-get install --yes apt-transport-https ca-certificates gnupg
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update
RUN apt install --yes google-cloud-sdk
RUN apt install --yes kubectl

# Install gh cli
RUN mkdir -p /tmp/gh && cd /tmp/gh && git clone https://github.com/cli/cli && cd cli && go build -o /usr/local/bin/gh ./cmd/gh && rm -rf /tmp/gh

# We need more inodes for vscode
ADD 10-inotify.conf /etc/sysctl.d/10-inotify.conf

RUN adduser --disabled-password --gecos "" justinsb

RUN echo "justinsb:justinsb" | chpasswd

#RUN usermod -aG sudo justinsb
RUN echo "justinsb ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/justinsb

ADD init-user.sh /tmp/init-user.sh
RUN su -l - justinsb /tmp/init-user.sh

# Install openstack clients
#RUN apt-get install --yes python3-swiftclient python3-keystoneclient python3-novaclient python3-openstackclient python3-octaviaclient

