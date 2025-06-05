FROM public.ecr.aws/spacelift/runner-terraform:latest AS builder

USER root

WORKDIR /opt/workspace
ADD main.tf /opt/workspace/main.tf



RUN apk add --update --virtual .deps --no-cache gnupg curl
RUN cd /tmp
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
RUN chmod +x install-opentofu.sh
RUN ./install-opentofu.sh --install-method apk
RUN mkdir -p /opt/.providers-cache
RUN cd /opt/workspace
RUN tofu init
RUN cp -r .terraform/providers/* /opt/.providers-cache
RUN mkdir -p /opt/.providers-cache/registry.terraform.io
RUN cp -r /opt/.providers-cache/registry.opentofu.org/* /opt/.providers-cache/registry.terraform.io
RUN chmod -R 777 /opt/.providers-cache
RUN rm -rf .terraform
RUN tofu init -plugin-dir=/opt/.providers-cache

FROM public.ecr.aws/spacelift/runner-terraform:latest

WORKDIR /opt/workspace
USER root

COPY --from=builder /opt/.providers-cache /opt/.providers-cache

RUN chown -R spacelift:spacelift /opt/.providers-cache \
    && chmod -R 777 /opt/.providers-cache


USER spacelift
