# Container with dependencies necessary to run note-c unit tests.

# Build development environment
# $ docker build . --tag note_c_run_unit_tests

# Launch development environment (mount source root as /note-c/)
# $ docker run --rm --volume $(pwd)/../../../:/note-c/ --workdir /note-c/ note_c_run_unit_tests

# Global Argument(s)
ARG DEBIAN_FRONTEND="noninteractive"
ARG UID=1000
ARG USER="blues"

# POSIX compatible (Linux/Unix) base image.
FROM --platform=linux/amd64 debian:stable-slim

# Import Global Argument(s)
ARG DEBIAN_FRONTEND
ARG UID
ARG USER

# Local Argument(s)

# Create Non-Root User
RUN ["dash", "-c", "\
    addgroup \
     --gid ${UID} \
     \"${USER}\" \
 && adduser \
     --disabled-password \
     --gecos \"\" \
     --ingroup \"${USER}\" \
     --uid ${UID} \
     \"${USER}\" \
 && usermod \
     --append \
     --groups \"dialout,plugdev\" \
     \"${USER}\" \
"]

# Install whatever dependencies we can via apt-get.
RUN ["dash", "-c", "\
    apt-get update --quiet \
 && apt-get install --assume-yes --no-install-recommends --quiet \
     astyle \
     ca-certificates \
     curl \
     g++ \
     gcc \
     gdb \
     git \
     lcov \
     make \
     nano \
     valgrind \
 && apt-get clean \
 && apt-get purge \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 "]

# Download and install CMake v3.25.1. We need CMake v3.20+ in order to get the
# ctest --test-dir option used by run_unit_tests.sh.
RUN ["dash", "-c", "\
    curl -LO https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-x86_64.tar.gz \
 && tar xf cmake-3.25.1-linux-x86_64.tar.gz --strip-components=1 -C /usr \
 && rm cmake-3.25.1-linux-x86_64.tar.gz \
"]

# Download and install Catch2 v3.2.1.
RUN ["dash", "-c", "\
    curl -LO https://github.com/catchorg/Catch2/archive/refs/tags/v3.2.1.tar.gz \
 && tar xf v3.2.1.tar.gz \
 && cd Catch2-3.2.1 \
 && cmake -DCATCH_INSTALL_DOCS=0 -B build/ \
 && cmake --build build/ --target install \
 && rm -rf Catch2-3.2.1  v3.2.1.tar.gz \
"]
