module("luci.controller.themes", package.seeall)

function index()
    entry({"admin", "themes"}, call("action_set_theme"), "Themes", 10)
    entry({"admin", "themes", "set_theme"}, call("action_set_theme"), "Set Theme", 10)
end

function action_set_theme()
    local http = require "luci.http"
    local uci = require "luci.model.uci".cursor()

    local theme = http.formvalue("theme")
    if theme then
        uci:set("luci", "main", "mediaurlbase", "/luci-static/" .. theme)
        uci:commit("luci")
        http.redirect(luci.dispatcher.build_url("admin", "themes"))
        return
    end

    luci.template.render("themes/index", {current_theme = uci:get("luci", "main", "mediaurlbase")})
end

