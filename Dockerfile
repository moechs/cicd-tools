ARG KANIKO_VERSION=1.23.2

FROM --platform=$TARGETPLATFORM gcr.io/kaniko-project/executor:v$KANIKO_VERSION AS builder

FROM --platform=$TARGETPLATFORM alpine

COPY --from=builder /kaniko /kaniko

ARG TARGETOS
ARG TARGETARCH
ARG TZ=Asia/Shanghai
ARG KUBECTL_VERSION=1.30.4
ARG KUSTOMIZE_VERSION=5.4.3
ARG HELM_VERSION=3.15.4
ARG SKAFFOLD_VERSION=2.13.2
ARG ARGOCD_VERSION=2.12.3
ARG FLUX_VERSION=2.3.0

ENV TZ=${TZ} \
    PATH=/kaniko:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin \
    DOCKER_CONFIG=/kaniko/.docker/ \
    DOCKER_CREDENTIAL_GCR_CONFIG=/kaniko/.config/gcloud/docker_credential_gcr_config.json \
    SSL_CERT_DIR=/kaniko/ssl/certs \
    SKAFFOLD_UPDATE_CHECK=false \
    SKAFFOLD_CACHE_ARTIFACTS=false \
    SKAFFOLD_INSECURE_REGISTRY="registry:5000" \
    GIT_SSL_NO_VERIFY=true



RUN set -ex && mkdir /workspace && cd /tmp && apk add --no-cache ca-certificates tzdata bash curl wget gawk grep git tar xz jq && \
    wget -O /usr/bin/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl && chmod +x /usr/bin/kubectl && \
    wget -O - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz|tar -xvz && mv kustomize /usr/bin/kustomize && chmod +x /usr/bin/kustomize && \ 
    wget -O - https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz|tar -xvz && mv ${TARGETOS}-${TARGETARCH}/helm /usr/bin/helm && chmod +x /usr/bin/helm && \
    wget -O /usr/bin/skaffold https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-${TARGETOS}-${TARGETARCH} && chmod +x /usr/bin/skaffold && \
    wget -O /usr/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-${TARGETOS}-${TARGETARCH} && chmod +x /usr/bin/argocd && \
    wget -O - https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz|tar -xvz && mv flux /usr/bin/flux && chmod +x /usr/bin/flux && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    rm -rf /tmp/*


WORKDIR /workspace

CMD ["bash"]
