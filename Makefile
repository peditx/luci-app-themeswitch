include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-themeswitch
PKG_RELEASE:=1.0.3
ARCH:=all

LUCI_TITLE:=Theme Switch
LUCI_DEPENDS:=+luci-base

PKG_MAINTAINER:=PeDitX <t.me/peditx>
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-themeswitch
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE=$(LUCI_TITLE)
  DEPENDS:=$(LUCI_DEPENDS)
endef

define Build/Compile
  # Nothing to compile, just copy the files
endef

define Package/luci-app-themeswitch/install
  # Copy files from the 'files' directory to the correct locations
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_BIN) ./files/themes.lua $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/themes
	$(INSTALL_DATA) ./files/index.htm $(1)/usr/lib/lua/luci/view/themes
endef

$(eval $(call BuildPackage,luci-app-themeswitch))
