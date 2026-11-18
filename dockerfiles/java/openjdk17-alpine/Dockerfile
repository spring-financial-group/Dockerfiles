FROM jx3mqubebuild.azurecr.io/docker-io/library/eclipse-temurin:17-jdk-alpine

# CVE-2026-114938 (Java4Shell): disables the vulnerable AVX-512 Base64 intrinsic until Temurin ships 17.0.21.1 GA.
ENV JAVA_TOOL_OPTIONS="-XX:-UseBASE64Intrinsics"
