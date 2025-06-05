FROM public.ecr.aws/spacelift/runner-terraform:latest AS builder

USER root

WORKDIR /opt/workspace
ADD main.tf /opt/workspace/main.tf



RUN apk add --update --virtual .deps --no-cache gnupg && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip && \
    wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_SHA256SUMS && \
    wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_SHA256SUMS.sig && \
    wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import && \
    gpg --verify terraform_1.5.7_SHA256SUMS.sig terraform_1.5.7_SHA256SUMS && \
    grep terraform_1.5.7_linux_amd64.zip terraform_1.5.7_SHA256SUMS | sha256sum -c && \
    unzip /tmp/terraform_1.5.7_linux_amd64.zip -d /tmp && \
    mv /tmp/terraform /usr/local/bin/terraform && \
    rm -f /tmp/terraform_1.5.7_linux_amd64.zip terraform_1.5.7_SHA256SUMS 1.5.7/terraform_1.5.7_SHA256SUMS.sig && \
    apk del .deps \
    && mkdir -p /opt/.providers-cache \
    && cd /opt/workspace \
    && terraform init \
    && cp -r .terraform/providers/* /opt/.providers-cache \
    && chmod -R 777 /opt/.providers-cache \
    && rm -rf .terraform \
    && terraform init -plugin-dir=/opt/.providers-cache

FROM public.ecr.aws/spacelift/runner-terraform:latest

WORKDIR /opt/workspace
USER root

COPY --from=builder /opt/.providers-cache /opt/.providers-cache

RUN chown -R spacelift:spacelift /opt/.providers-cache \
    && chmod -R 777 /opt/.providers-cache


USER spacelift
