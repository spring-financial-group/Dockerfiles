FROM mcr.microsoft.com/dotnet/sdk:10.0-bookworm-slim

# Unlike the net8 image, no libssl1.1 install is needed: Mongo2Go 5+ bundles
# MongoDB 8, which links libssl.so.3 (shipped with bookworm). Services on this
# image must use Mongo2Go 5.0.0 or later.
CMD ["bash"]
