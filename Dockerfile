#syntax=nobidev/dockerfile
FROM debian:bookworm-slim

RUN <<-EOF
	apt-get -qq update
	apt-get -qq install -y git gcc make liblzma-dev isolinux mkisofs
EOF

WORKDIR /build
COPY src/ ./

RUN make -j$(nproc) bin/undionly.kpxe EMBED=embed.ipxe
RUN make -j$(nproc) bin/ipxe.lkrn EMBED=embed.ipxe

FROM debian:bookworm-slim

RUN <<-EOF
	apt-get -qq update
	apt-get -qq install -y git gcc make libelf-dev zlib1g-dev isolinux mkisofs
EOF

WORKDIR /build
COPY src/ ./

RUN sed -i -E 's|^#define PXE_CMD|//\0|' config/general.h

RUN make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=embed.ipxe

FROM debian:bookworm-slim

COPY --from=0 /build/bin/undionly.kpxe /build/bin/ipxe.lkrn /
COPY --from=1 /build/bin-x86_64-efi/ipxe.efi /
