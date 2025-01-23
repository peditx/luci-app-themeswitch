include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-themeswitch
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=PeDitX <https://t.me/peditx>
PKG_LICENSE:=GPL-2.0

LUCI_TITLE:=Theme Switcher for LuCI
LUCI_DEPENDS:=+luci

LUCI_FILES:= \
    /usr/lib/lua/luci/controller/themes.lua \
    /usr/lib/lua/luci/view/themes/index.htm

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/themes
	$(CP) ./files/themes.lua $(1)/usr/lib/lua/luci/controller/
	$(CP) ./files/index.htm $(1)/usr/lib/lua/luci/view/themes/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
