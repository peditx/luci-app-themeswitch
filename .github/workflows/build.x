name: Build and Release luci-app-themeswitch

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential libncurses5-dev gawk git gettext unzip zlib1g-dev file python3 python3-venv curl ninja-build

      - name: Setup OpenWrt SDK
        run: |
          wget https://downloads.openwrt.org/releases/23.05.0/targets/x86/64/openwrt-sdk-23.05.0-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz
          mkdir sdk && tar -xJf openwrt-sdk-23.05.0-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz -C sdk --strip-components=1
          cd sdk
          echo "src-git packages https://github.com/openwrt/packages.git" > feeds.conf.default
          echo "src-git luci https://github.com/openwrt/luci.git" >> feeds.conf.default
          ./scripts/feeds update -a
          ./scripts/feeds install -a

      - name: Remove lucihttp dependency
        run: |
          cd sdk
          sed -i '/CONFIG_PACKAGE_lucihttp/d' .config

      - name: Add luci-app-themeswitch package
        run: |
          cd sdk/package
          git clone https://github.com/peditx/luci-app-themeswitch
          cd ..
          echo "CONFIG_PACKAGE_luci-app-themeswitch=m" >> .config

      - name: Build luci-app-themeswitch
        run: |
          cd sdk
          make defconfig
          make package/luci-app-themeswitch/compile -j1 V=sc

      - name: Save luci-app-themeswitch package
        run: |
          cd sdk
          mkdir -p artifacts
          find bin/ -name "*.ipk" -exec cp {} artifacts/ \;

      - name: Create Release
        id: create_release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v1.0.2
          name: luci-app-themeswitch release - ${{env.timestamp}}
          body: latest release of luci-app-themeswitch for OpenWrt.
          files: sdk/artifacts/luci-app-themeswitch_*.ipk
        env:
          GITHUB_TOKEN: ${{ secrets.MY_GITHUB_TOKEN }}
          timestamp: ${{ github.run_id }}