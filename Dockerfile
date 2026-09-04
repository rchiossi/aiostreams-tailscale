# Step 1: Pull the official image to extract the pre-compiled app
FROM ghcr.io/viren070/aiostreams:latest AS upstream

# Step 2: Use a standard Node environment that includes apt, bash, and networking tools
FROM node:22-bookworm-slim

# Install dependencies required by the Unraid Tailscale integration hook
RUN apt-get update && apt-get install -y \
    curl \
    iptables \
    iproute2 \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the pre-built application from the official image
COPY --from=upstream /app /app

# The official image relies on node being specifically at /nodejs/bin/node. 
# We create a symlink so the original startup commands work seamlessly.
RUN mkdir -p /nodejs/bin && ln -s /usr/local/bin/node /nodejs/bin/node

WORKDIR /app

EXPOSE 3000

ENTRYPOINT ["/nodejs/bin/node"]
CMD ["/app/packages/server/dist/server.js"]
