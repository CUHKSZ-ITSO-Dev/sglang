# syntax=docker/dockerfile:1
#
# Production overlay image for this fork.
#
# The fork only changes pure-Python scheduler code on top of an upstream
# release. The official release image installs SGLang in editable mode from
# /sgl-workspace/sglang/python, so copying the changed files over that tree is
# enough: torch, CUDA, sglang-kernel, DeepGEMM and FlashInfer stay byte-for-byte
# identical to the upstream image, and existing JIT caches keep matching.
#
# Rules (enforced by .github/workflows/release-overlay-image.yml):
#   * BASE_SGLANG_COMMIT must be the commit the base image was built from
#     (its ai.sglang.build.commit label) and an ancestor of the built commit.
#   * Every python/sglang/**/*.py file changed since BASE_SGLANG_COMMIT is
#     listed below, and nothing else. Any change outside python/, test/ and
#     docs/ (kernels, Rust, pyproject, ...) cannot use this overlay.
#   * Only COPY --link and metadata instructions. No RUN: that keeps BuildKit
#     from unpacking the ~16 GB base image, so a GitHub-hosted runner can build it.
#
# To move to a new upstream release: merge the release tag into this branch,
# update BASE_IMAGE and BASE_SGLANG_COMMIT, then refresh the COPY list.

ARG BASE_IMAGE=lmsysorg/sglang:v0.5.23@sha256:f832b5c39559c9caa900b22ad37c76fcce66470676855c42052102c537812f1f
ARG BASE_SGLANG_COMMIT=297e54fd105e974cdf401e5b4d20253a22c16f90

FROM ${BASE_IMAGE}

COPY --link python/sglang/srt/arg_groups/field_order.py /sgl-workspace/sglang/python/sglang/srt/arg_groups/field_order.py
COPY --link python/sglang/srt/arg_groups/fields/schedule.py /sgl-workspace/sglang/python/sglang/srt/arg_groups/fields/schedule.py
COPY --link python/sglang/srt/arg_groups/pipeline.py /sgl-workspace/sglang/python/sglang/srt/arg_groups/pipeline.py
COPY --link python/sglang/srt/arg_groups/resolution_hooks.py /sgl-workspace/sglang/python/sglang/srt/arg_groups/resolution_hooks.py
COPY --link python/sglang/srt/arg_groups/validation_hook.py /sgl-workspace/sglang/python/sglang/srt/arg_groups/validation_hook.py
COPY --link python/sglang/srt/dllm/mixin/scheduler.py /sgl-workspace/sglang/python/sglang/srt/dllm/mixin/scheduler.py
COPY --link python/sglang/srt/managers/schedule_batch.py /sgl-workspace/sglang/python/sglang/srt/managers/schedule_batch.py
COPY --link python/sglang/srt/managers/schedule_policy.py /sgl-workspace/sglang/python/sglang/srt/managers/schedule_policy.py
COPY --link python/sglang/srt/managers/scheduler.py /sgl-workspace/sglang/python/sglang/srt/managers/scheduler.py

ARG BASE_IMAGE
ARG BASE_SGLANG_COMMIT
ARG OVERLAY_COMMIT=unknown
ARG OVERLAY_TAG=local
ENV SGLANG_OVERLAY_COMMIT=${OVERLAY_COMMIT} \
    SGLANG_OVERLAY_TAG=${OVERLAY_TAG}
LABEL org.opencontainers.image.source="https://github.com/CUHKSZ-ITSO-Dev/sglang" \
      org.opencontainers.image.revision="${OVERLAY_COMMIT}" \
      org.opencontainers.image.version="${OVERLAY_TAG}" \
      org.opencontainers.image.base.name="${BASE_IMAGE}" \
      ai.sglang.overlay.base_commit="${BASE_SGLANG_COMMIT}"
