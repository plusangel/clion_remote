# CLion remote docker environment (How to build docker container, run and stop it)
#
# Build and run:
#   docker build -t clion/remote-cpp-env:0.5 -f Dockerfile.remote-cpp-env .
#   docker run -d --cap-add sys_ptrace -p127.0.0.1:2222:22 --name clion_remote_env clion/remote-cpp-env:0.5
#   ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"
#
# stop:
#   docker stop clion_remote_env
#
# ssh credentials (test user):
#   user@password

FROM ubuntu:18.04

ARG BOOST_VERSION=1.72.0
ARG BOOST_DIR=boost_1_72_0
ARG CMAKE_VERSION=3.15
ARG CMAKE_DIR=cmake-3.15.7

RUN apt-get update \
  && apt-get install -y ssh \
      build-essential \
      gcc \
      g++ \
      gdb \
      clang \
      rsync \
      tar \
  && apt-get clean

RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_config_test_clion \
  && mkdir /run/sshd

# install the most recent version of boost libraries (not all - actually to support asio)
RUN cd /home && wget https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/${BOOST_DIR}.tar.gz \
  && tar xfz ${BOOST_DIR}.tar.gz \
  && rm ${BOOST_DIR}.tar.gz \
  && cd ${BOOST_DIR} \
  && ./bootstrap.sh --prefix=/usr/local \
  && ./b2 --with-system --with-thread --with-date_time --with-regex --with-serialization install \
  && cd /home \
  && rm -rf ${BOOST_DIR}

# install the most recent version of cmake
ADD https://cmake.org/files/v${CMAKE_VERSION}/${CMAKE_DIR}-Linux-x86_64.sh /${CMAKE_DIR}-Linux-x86_64.sh
RUN mkdir /opt/cmake
RUN sh /${CMAKE_DIR}-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version


RUN useradd -m user \
  && yes password | passwd user

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config_test_clion"]