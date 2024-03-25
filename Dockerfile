FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine AS builder_cloud_sdk

# Install gcloud auth plugin, kubectl and helm
RUN apk --update --no-cache add curl

FROM alpine:3.19 AS builder_tfenv

# Install tfenv
RUN apk add --no-cache bash git curl && \
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
	ln -s /root/.tfenv/bin/* /usr/local/bin && \
	tfenv install 1.7.3


FROM alpine:3.19
# Add gcloud to the path
ENV PATH /google-cloud-sdk/bin:$PATH

# Install dependencies
RUN apk add --no-cache python3 bash jq

# Copy binaries from the builder
COPY --from=builder_cloud_sdk google-cloud-sdk/lib /google-cloud-sdk/lib
COPY --from=builder_cloud_sdk google-cloud-sdk/bin/gcloud google-cloud-sdk/bin/gcloud
COPY --from=builder_tfenv /usr/local/bin/tfenv /usr/local/bin/tfenv

# Update gcloud config
RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

# Set the default configuration directory
VOLUME ["/root/.config"]