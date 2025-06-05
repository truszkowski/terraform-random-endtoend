FROM ubuntu:24.04 AS builder

WORKDIR /home/ubuntu/workspace
ADD main.tf main.tf

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    gnupg \
    software-properties-common \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get install -y terraform \
    && mkdir -p /home/ubuntu/.providers-cache \
    && terraform init \
    && cp -r .terraform/providers/* /home/ubuntu/.providers-cache \
    && rm -rf .terraform \
    && terraform init -plugin-dir=/home/ubuntu/.providers-cache

FROM ubuntu:24.04

WORKDIR /home/ubuntu/workspace

COPY --from=builder /home/ubuntu/.providers-cache /home/ubuntu/.providers-cache
