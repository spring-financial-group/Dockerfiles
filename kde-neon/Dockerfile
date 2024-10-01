FROM invent-registry.kde.org/neon/docker-images/plasma:developer

# Passwordless sudo for neon user
USER root
RUN usermod -aG sudo neon
RUN echo "neon ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER neon

CMD ["bash", "-c", "echo 'Hello World!' && whoami && bash"]
