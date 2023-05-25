# // Sources
# https://github.com/ambakshi/docker-perforce
# https://github.com/hawkmoth-studio/perforce-docker
# https://aricodes.net/posts/perforce-server-with-docker/
# https://www.froyok.fr/blog/2018-09-setting-up-perforce-with-docker-for-unreal-engine-4/#modifying_the_docker_image

#default version
ARG P4_VERSION=23.1
ARG P4_DISTRO=focal

FROM ubuntu:${P4_DISTRO}

# Update Ubuntu System
RUN apt-get update
RUN apt-get upgrade -y

# Install required packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
		wget \
		gnupg \
		gosu \
		software-properties-common
		
# Cleanup
#RUN rm -rf /var/lib/apt/lists/*

# After a "FROM" instruction, ARGs are collected and no longer available. Need to "get" it again
# https://stackoverflow.com/questions/44438637/arg-substitution-in-run-command-not-working-for-dockerfile
ARG P4_VERSION
ARG P4_DISTRO

# Add Perforce package and update it
RUN wget -qO - https://package.perforce.com/perforce.pubkey | gpg --dearmor | tee /etc/apt/trusted.gpg.d/perforce.gpg
RUN apt-add-repository -y "deb https://package.perforce.com/apt/ubuntu ${P4_DISTRO} release"
RUN apt-get update

# Output available versions to console (debugging)
# RUN apt-cache policy helix-p4d

# Install the specified version - MUST install Helix-p4d-base first to avoid dependency issues when installing a custom version
RUN apt-get install -y helix-p4d-base=20${P4_VERSION}-*
RUN apt-get install -y helix-p4d=20${P4_VERSION}-*

# Final cleanup..?
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean all

# Expose the port
EXPOSE 1666

# Set default variables
ENV DATAVOLUME				/data
ENV P4SVCNAME				PerforceMaster
ENV P4PORT					ssl:1666
ENV P4USER					JBaxter
ENV P4PASSWD				defaultPassword123
ENV P4ROOT					${DATAVOLUME}/${P4SVCNAME}
ENV P4SSLDIR				${P4ROOT}/root/ssl
ENV P4_NO_DEFAULT_DEPOT		true
ENV P4D_SECURITY			2

# Seems to creates a volume?
VOLUME ["${DATAVOLUME}"]

# Copy instead of ADD as ADD prevents files being visible.
# Documentation also suggests using COPY when you don't need the "magic" of ADD
COPY ./docker-startup.d/	/docker-startup.d/
COPY ./setup-perforce.sh	/

# Entrypoint instead of CMD seems to preserve ENV variables..
ENTRYPOINT ["/setup-perforce.sh"]

# Run perforce. Use p4d to run, as using p4dctl will exit instantly
CMD gosu perforce p4d -r "${P4ROOT}"/root -p "${P4PORT}"