FROM alpine AS builder
WORKDIR /aggregator
ARG TARGETPLATFORM
COPY clash /aggregator/clash
COPY subconverter /aggregator/subconverter
COPY subscribe /aggregator/subscribe
COPY requirements.txt /aggregator/requirements.txt
RUN set -ex \
    && rm -rf clash/clash-darwin* clash/clash-windows* subconverter/subconverter-darwin* subconverter/subconverter-windows* \
    && case "$TARGETPLATFORM" in \
    "linux/amd64") rm -rf clash/clash-linux-arm* subconverter/subconverter-linux-arm* ;; \
    "linux/arm64") rm -rf clash/clash-linux-amd* subconverter/subconverter-linux-amd* ;; \
    esac
FROM python:alpine AS dist
WORKDIR /aggregator
ENV CUSTOMIZE_LINK="" \
    ENABLE_SPECIAL_PROTOCOLS="true" \
    GIST_LINK="" \
    GIST_PAT=""
COPY --from=builder /aggregator /aggregator
RUN set -ex \
    && python -V \
    && python -m pip install --no-cache-dir --root-user-action=ignore -r requirements.txt
CMD ["python", "-u", "subscribe/collect.py", "--all", "--overwrite", "--skip"]
