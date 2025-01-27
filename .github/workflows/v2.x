name: Build and Release luci-app-themeswitch

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  MY_GITHUB_TOKEN: ${{ secrets.MY_GITHUB_TOKEN }}

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch:
          - aarch64_cortex-a53
          - aarch64_cortex-a72
          - aarch64_generic
          - arm_cortex-a15_neon-vfpv4
          - arm_cortex-a5_vfpv4
          - arm_cortex-a7
          - arm_cortex-a7_neon-vfpv4
          - arm_cortex-a8_vfpv3
          - arm_cortex-a9
          - arm_cortex-a9_neon
          - arm_cortex-a9_vfpv3-d16
          - mipsel_24kc
          - mipsel_74kc
          - mipsel_mips32
          - mips_24kc
          - mips_4kec
          - mips_mips32
          - x86_64
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up Docker
        run: |
          sudo apt-get update
          sudo apt-get install -y docker.io
          sudo systemctl start docker
          sudo systemctl enable docker

      - name: Pull OpenWrt SDK Docker image
        run: |
          docker pull openwrt/sdk:${{ matrix.arch }}-openwrt-23.05

      - name: Build for ${{ matrix.arch }}
        run: |
          docker run --rm -v $(pwd):/workspace -w /workspace openwrt/sdk:${{ matrix.arch }}-openwrt-23.05 /bin/bash -c "
            git clone https://github.com/peditx/luci-app-themeswitch package/luci-app-themeswitch &&
            echo 'CONFIG_PACKAGE_luci-app-themeswitch=m' >> .config &&
            ./scripts/feeds update -a &&
            ./scripts/feeds install -a &&
            make defconfig &&
            make package/luci-app-themeswitch/compile -j$(nproc) V=sc
          "

      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: luci-app-themeswitch_${{ matrix.arch }}
          path: bin/packages/${{ matrix.arch }}/base/luci-app-themeswitch_1_${{ matrix.arch }}.ipk

  release:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v3
        with:
          path: artifacts

      - name: Create release
        id: create_release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ env.MY_GITHUB_TOKEN }}
        with:
          tag_name: $(date +'%Y-%m-%d')
          release_name: Release $(date +'%Y-%m-%d')
          body: "Latest version of the software with support for 17 OpenWrt architectures (v23.05)"
          draft: false
          prerelease: false

      - name: Upload release assets
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ env.MY_GITHUB_TOKEN }}
        with:
          upload_url: ${{ steps.create_release.outputs.upload_url }}
          asset_path: artifacts/luci-app-themeswitch_${{ matrix.arch }}/luci-app-themeswitch_1_${{ matrix.arch }}.ipk
          asset_name: luci-app-themeswitch_1_${{ matrix.arch }}.ipk
          asset_content_type: application/octet-stream