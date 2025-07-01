#syntax=nobidev/dockerfile
FROM debian:bookworm-slim

RUN <<-EOF
	apt-get -qq update
	apt-get -qq install -y git gcc make liblzma-dev isolinux mkisofs
EOF

WORKDIR /build
COPY src/ ./

RUN make -j$(nproc) bin/undionly.kpxe EMBED=embed.ipxe
