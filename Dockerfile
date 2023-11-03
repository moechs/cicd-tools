FROM --platform=$TARGETPLATFORM gcr.io/kaniko-project/executor:v$KANIKO_VERSION AS builder

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG TZ=Asia/Shanghai
ARG KUBECTL_VERSION=1.28.3
ARG KUSTOMIZE_VERSION=5.2.1
ARG HELM_VERSION=3.13.1
ARG SKAFFOLD_VERSION=2.8.0
ARG KANIKO_VERSION=1.17.0
ARG ARGOCD_VERSION=2.8.6

USER root

ENV HOME=/root \
    USER=root \
    TZ=${TZ} \
    PATH=/kaniko:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin \
    DOCKER_CONFIG=/kaniko/.docker/ \
    DOCKER_CREDENTIAL_GCR_CONFIG=/kaniko/.config/gcloud/docker_credential_gcr_config.json \
    SSL_CERT_DIR=/kaniko/ssl/certs \
    SKAFFOLD_UPDATE_CHECK=false \
    SKAFFOLD_CACHE_ARTIFACTS=false \
    SKAFFOLD_INSECURE_REGISTRY="registry:5000"

FROM --platform=$TARGETPLATFORM alpine

COPY --from=builder /kaniko /kaniko

RUN mkdir /workspace && cd /tmp && apk add --no-cache ca-certificates tzdata bash curl wget gawk grep git tar xz jq && \
    wget -O /usr/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" && chmod +x /usr/bin/kubectl && \
    wget -O - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${TARGETOS}_${TARGETARCH}}.tar.gz|tar -xvz && mv kustomize /usr/bin/kustomize && chmod +x /usr/bin/kustomize && \ 
    wget -O - https://get.helm.sh/helm-v${HELM_VERSION}}-${TARGETOS}-${TARGETARCH}.tar.gz|tar -xvz && mv ${TARGETOS}-${TARGETARCH}/helm /usr/bin/helm && chmod +x /usr/bin/helm && \
    wget -O /usr/bin/skaffold https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-${TARGETOS}-${TARGETARCH} && chmod +x /usr/bin/skaffold && \
    wget -O /usr/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-${TARGETOS}-${TARGETARCH} && chmod +x /usr/bin/argocd && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    rm -rf /tmp/*


WORKDIR /workspace

CMD ["bash"]