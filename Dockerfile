# Install and build gitfs for unbuntu-20
# Define ARGS before anything else, to use them in the FROM directives
ARG BASE_IMAGE=mcr.microsoft.com/playwright:v1.23.0-focal

FROM $BASE_IMAGE as gitfs-builder

WORKDIR /keg/gitfs
COPY . /keg/gitfs

RUN apt-get update; \
    apt-get install -qy --no-install-recommends \
    gcc \
    virtualenv \
    python-dev \
    libfuse-dev \
    fuse \
    libffi-dev \
    libgit2-dev \
    python3-pip \
    python3.8-venv && \
    apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove

RUN cd /keg/gitfs; \
    python3 -m pip install build; \
    python3 -m build

