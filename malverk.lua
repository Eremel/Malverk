Malverk = SMODS.current_mod
Malverk.badges = {}
Malverk.android_mode = love.system.getOS() == "Android"
Malverk.pending_update = false

assert(SMODS.load_file('api/AltTexture.lua'))()
assert(SMODS.load_file('utils/keys.lua'))()
assert(SMODS.load_file('utils/ui.lua'))()
if Malverk.testing then SMODS.load_file('testing/test.lua')() end

function Malverk.safe_to_update()
    if not Malverk.android_mode then return true end
    if G and G.CONTROLLER and G.CONTROLLER.dragging then
        local d = G.CONTROLLER.dragging
        if d.target ~= nil then
            return false
        end
    end
    return true
end

function Malverk.safe_refresh_cards()
    for _, card in pairs(G.I.CARD or {}) do
        if not card.being_dragged and card.set_sprites and card.config then
            local center = G.P_CENTERS[card.config.center_key]
            if center then
                pcall(function()
                    card:set_sprites(center)
                end)
            end
        end
    end
end

local old_game_update = Game.update
function Game:update(dt)
    old_game_update(self, dt)
end

function Malverk.set_defaults()
    local pack = TexturePacks and TexturePacks['default']
    if not pack or not pack.textures then return end
    for _, key in pairs(pack.textures) do
        local texture = AltTextures[key]
        local game_table = AltTextures_Utils.game_table[texture.set] or 'P_CENTERS'
        for _, center in ipairs(texture.keys or {}) do
            if G[game_table][center] then
                if texture.set == 'Seal' then
                    G.P_SEALS[center].default_pos = G.P_SEALS[center].default_pos or copy_table(G[game_table][center].sprite_pos)
                    G[game_table][center]:remove()
                    G[game_table][center] = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS['centers'], G.P_SEALS[center].default_pos)
                else
                    G[game_table][center].atlas = texture.atlas.key
                end
                if center == 'c_soul' then
                    G.default_soul = G.default_soul or Sprite(0,0,G.CARD_W,G.CARD_H,G.ASSET_ATLAS["centers"],G.P_CENTERS.soul.pos)
                    G.shared_soul = G.default_soul
                end
                G[game_table][center].default_pos = G[game_table][center].default_pos or G[game_table][center].pos
                G[game_table][center].pos = G[game_table][center].default_pos
                G[game_table][center].default_soul = G[game_table][center].default_soul or (G[game_table][center].soul_pos and copy_table(G[game_table][center].soul_pos) or "1")
                if G[game_table][center].default_soul == "1" then
                    G[game_table][center].soul_pos = false
                else
                    G[game_table][center].soul_pos = G[game_table][center].default_soul
                end
                if texture.set == "Stake" or texture.set == 'Sticker' then
                    G.default_stickers = G.default_stickers or Malverk.copy_stickers()
                    for k, v in pairs(G.default_stickers) do
                        G.shared_stickers[k]:remove()
                        G.shared_stickers[k] = Sprite(0,0,G.CARD_W,G.CARD_H,G.ASSET_ATLAS[v.atlas.name or v.atlas.key],v.sprite_pos)
                        if G['shared_sticker_'..k] then
                            G['shared_sticker_'..k]:remove()
                            G['shared_sticker_'..k] = Sprite(0,0,G.CARD_W,G.CARD_H,G.ASSET_ATLAS[v.atlas.name or v.atlas.key],v.sprite_pos)
                        end
                    end
                end
                G[game_table][center].default_card_type_badge =
                    G[game_table][center].default_card_type_badge or
                    (G[game_table][center].set_card_type_badge and copy_table(G[game_table][center].set_card_type_badge) or '1')
                if G[game_table][center].default_card_type_badge == '1' then
                    G[game_table][center].set_card_type_badge = false
                else
                    G[game_table][center].set_card_type_badge = G[game_table][center].default_card_type_badge
                end
                G[game_table][center].default_loc_txt =
                    G[game_table][center].default_loc_txt or
                    copy_table(G.localization.descriptions[AltTextures_Utils.loc_table[texture.set] or texture.set][center])
                local default_loc = G[game_table][center].default_loc_txt
                SMODS.process_loc_text(G.localization.descriptions[AltTextures_Utils.loc_table[texture.set] or texture.set][center],'name',default_loc,'name')
                SMODS.process_loc_text(G.localization.descriptions[AltTextures_Utils.loc_table[texture.set] or texture.set][center],'text',default_loc,'text')
            end
        end
    end
    init_localization()
end

function Malverk.update_atlas(atlas_type)
    if not Malverk.safe_to_update() then return end
    if table.size(TexturePacks) == 0 then return end
    Malverk.set_defaults()
    for _, pack_key in ipairs(Malverk.config.selected) do
        local pack = TexturePacks[pack_key]
        if pack then
            if pack.key == 'default' then
                Malverk.set_defaults()
            else
                for _, key in pairs(pack.textures) do
                    if Malverk.config.texture_configs[pack_key][key] then
                        local texture = AltTextures[key]
                        local game_table = AltTextures_Utils.game_table[texture.set] or 'P_CENTERS'
                        local soul_count = 0
                        for i, center in ipairs(texture.keys or {}) do
                            if G[game_table][center] then
                                if texture.set == 'Seal' then
                                    G[game_table][center]:remove()
                                    G[game_table][center] = Sprite(
                                        0,0,G.CARD_W,G.CARD_H,
                                        G.ASSET_ATLAS[texture.atlas.key],
                                        (texture.columns and not texture.original_sheet and Malverk.get_pos_on_sheet(center,texture)
                                        or G.P_SEALS[center].default_pos)
                                    )
                                else
                                    G[game_table][center].atlas = texture.atlas.key
                                end
                                if texture.columns and not texture.original_sheet then
                                    G[game_table][center].pos = {
                                        x=(i+soul_count-1)%texture.columns,
                                        y=math.floor((i+soul_count-1)/texture.columns)
                                    }
                                else
                                    G[game_table][center].pos = G[game_table][center].default_pos or G[game_table][center].pos
                                end
                                if center == 'c_soul' then
                                    if texture.soul then
                                        G.shared_soul:remove()
                                        G.shared_soul = Sprite(
                                            0,0,G.CARD_W,G.CARD_H,
                                            G.ASSET_ATLAS[texture.soul_atlas.key],
                                            G.P_CENTERS.soul.pos
                                        )
                                    else
                                        G.shared_soul = G.default_soul
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    Malverk.safe_refresh_cards()
    init_localization()
end

Malverk.update_stake = function(stake_key, texture, i)
    local table
    for _, v in ipairs(G.P_CENTER_POOLS.Stake) do
        if v.key == stake_key then table = v end
    end
    if not table then return end
    table.atlas = texture.atlas.key
    if texture.columns and not texture.original_sheet then
        table.pos = {x=(i-1)%texture.columns, y=math.floor((i-1)/texture.columns)}
    else
        table.pos = table.default_pos or table.pos
    end
    local default_loc = table.default_loc_txt
    local new_loc = {}
    if texture.localisation and texture.localisation[stake_key] then
        new_loc = texture.localisation[stake_key]
    end
    SMODS.process_loc_text(G.localization.descriptions[AltTextures_Utils.loc_table[texture.set] or texture.set][stake_key],'name',new_loc.name or default_loc.name,'name')
    SMODS.process_loc_text(G.localization.descriptions[AltTextures_Utils.loc_table[texture.set] or texture.set][stake_key],'text',new_loc.text or default_loc.text,'text')
end

Malverk.copy_stickers = function()
    local stickers = {}
    for k, v in pairs(G.shared_stickers) do
        stickers[k] = Sprite(0,0,G.CARD_W,G.CARD_H,
            G.ASSET_ATLAS[v.atlas and (v.atlas.name or v.atlas.key) or 'stickers'],
            v.sprite_pos)
    end
    return stickers
end

local main_menu = Game.main_menu
function Game:main_menu(context)
    Malverk.update_atlas()
    main_menu(self, context)
end

local load_profile_ref = G.FUNCS.load_profile
G.FUNCS.load_profile = function(delete_prof_data)
    Malverk.set_defaults()
    load_profile_ref(delete_prof_data)
end

SMODS.Atlas.pre_inject_class = nil
