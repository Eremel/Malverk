AltTextures = {}
AltTextures_Utils = {}
AltTextures_Utils.selectors = {}
AltTextures_Utils.dimensions = {
    Tag = {px = 34, py = 34},
    Blind = {px = 34, py = 34},
    Chips = {px = 29, py = 29},
    Stake = {px = 29, py = 29}
}
AltTextures_Utils.default_atlas = {
    Enhanced = 'centers',
    Back = 'centers',
    Seal = 'centers',
    Tag = 'tags',
    Blind = 'blind_chips',
    Stake = 'chips',
    Sticker = 'stickers'
}
AltTextures_Utils.game_table = {
    Tag = 'P_TAGS',
    Seal = 'shared_seals',
    Blind = 'P_BLINDS',
    Stake = 'P_STAKES',
    Sticker = 'shared_stickers'
}
AltTextures_Utils.sprite_layer = {
    Blind = 'animatedSprite'
}
AltTextures_Utils.loc_table = {
    Booster = 'Other',
    Seal = 'Other',
    Sticker = 'Other'
}
AltTextures_Utils.sticker_key = {
    stake_white = 'White',
    stake_red = 'Red',
    stake_green = 'Green',
    stake_black = 'Black',
    stake_blue = 'Blue',
    stake_purple = 'Purple',
    stake_orange = 'Orange',
    stake_gold = 'Gold'
}
AltTextures_Utils.texture_types = {
    'Joker', 'Tarot', 'Planet', 'Spectral', 'Enhanced',
    'Seal', 'Blind', 'Tag', 'Back', 'Voucher',
    'Booster', 'Stake'
}
AltTextures_Utils.loc_keys = {
    Joker = 'b_jokers',
    Tarot = 'b_tarot_cards',
    Planet = 'b_planet_cards',
    Spectral = 'b_spectral_cards',
    Enhanced = 'b_enhanced_cards',
    Seal = 'b_seals',
    Blind = 'b_blinds',
    Tag = 'b_tags',
    Back = 'b_decks',
    Voucher = 'b_vouchers',
    Booster = 'b_booster_packs',
    Stake = 'b_stake',
    Sticker = 'k_joker_stickers',
}

function check_type_present(type)
    local exists = false
    for _, v in ipairs(AltTextures_Utils.texture_types) do
        if v == type then exists = true end
    end
    if not exists then table.insert(AltTextures_Utils.texture_types, type) end
end

function Malverk.get_keys_from_pool(set)
    local pool = G.P_CENTER_POOLS[set]
    local keys = {}
    for _, v in ipairs(pool) do
        keys[#keys + 1] = v.key
    end
    return keys
end


AltTexture = SMODS.GameObject:extend {
    obj_table = AltTextures,
    obj_buffer = {},
    required_params = {
        'key', -- same as atlas key
        'set', -- type to apply atlas to
    },
    class_prefix = 'alt_tex',
    set = 'AltTexture',
    process_loc_text = function(self)
        SMODS.process_loc_text(G.localization.descriptions.alt_texture, self.key, self.loc_txt)
    end,
    inject = function(self)
        G.localization.descriptions.alt_texture = G.localization.descriptions.alt_texture or {default = {name = 'Default', text = {'Example description'}}}
        -- ensure type exists
        if not G.P_CENTER_POOLS[self.set] and self.set ~= 'Blind' and self.set ~= 'Sticker' then sendWarnMessage(self.set .. ' does not exist. Texture '..self.key..' not injected.', 'Malverk: Alt Texture Initialization'); return end
        check_type_present(self.set)
        if self.frames then self.animated = true end
        -- create the atlas for the new texture
        local atlas = SMODS.Atlas({
            key = self.key,
            path = self.path,
            px = self.px or AltTextures_Utils.dimensions[self.set] and AltTextures_Utils.dimensions[self.set].px or 71, -- px and py are not required
            py = self.py or AltTextures_Utils.dimensions[self.set] and AltTextures_Utils.dimensions[self.set].py or 95,
            obj_table = {},
            obj_buffer = {},
            atlas_table = self.animated and 'ANIMATION_ATLAS' or 'ASSET_ATLAS',
            set = 'Atlas',
            frames = self.frames or nil,
            mod = self.mod
        })
        atlas:inject()
        if self.soul then
            local soul_atlas = SMODS.Atlas({
                key = self.key..'_soul',
                path = self.soul,
                px = self.px or AltTextures_Utils.dimensions[self.set] and AltTextures_Utils.dimensions[self.set].px or 71, -- px and py are not required
                py = self.py or AltTextures_Utils.dimensions[self.set] and AltTextures_Utils.dimensions[self.set].py or 95,
                obj_table = {},
                obj_buffer = {},
                atlas_table = 'ASSET_ATLAS',
                set = 'Atlas',
                mod = self.mod
            })
            soul_atlas:inject()
            self.soul_atlas = G.ASSET_ATLAS[self.key..'_soul']
        end
        if self.stickers then
            local dot_pos = string.find(self.path, "%.")
            local sticker_atlas = SMODS.Atlas({
                key = self.key..'_stickers',
                path = string.sub(self.path,1,dot_pos - 1)..'_stickers'..string.sub(self.path, dot_pos),
                px = self.sticker_px or 71, -- px and py are not required
                py = self.sticker_py or 95,
                obj_table = {},
                obj_buffer = {},
                atlas_table = 'ASSET_ATLAS',
                set = 'Atlas',
                mod = self.mod
            })
            sticker_atlas:inject()
            self.stickers = G.ASSET_ATLAS[self.key..'_stickers']
        end
        -- store the atlas
        self.atlas = self.animated and G.ANIMATION_ATLAS[self.key] or G.ASSET_ATLAS[self.key]
        self.columns = math.floor(self.atlas.image:getWidth()/self.atlas.px); self.original_sheet = self.original_sheet or not self.keys
        self.keys = self.keys or Malverk.keys[self.set] or Malverk.get_keys_from_pool(self.set)
        -- if first texture, create default texture
        if not AltTextures_Utils.selectors[self.set] then
            AltTextures_Utils.selectors[self.set] = {self.set}
            AltTextures[self.set] = {atlas = {}, keys = Malverk.keys[self.set] or Malverk.get_keys_from_pool(self.set), set = self.set}
            for k,v in pairs(self.animated and G.ANIMATION_ATLAS[AltTextures_Utils.default_atlas[self.set] or self.set] or G.ASSET_ATLAS[AltTextures_Utils.default_atlas[self.set] or self.set]) do
                AltTextures[self.set].atlas[k] = v
            end
            SMODS.process_loc_text(G.localization.descriptions.alt_texture, self.set, {name = 'Default '..self.set, text = {'Base game texture'}})
        end
        table.insert(AltTextures_Utils.selectors[self.set], self.key)
    end
}

TexturePacks = {}
TexturePacks_Utils = {keys = {'default'}}

TexturePack = SMODS.GameObject:extend {
    obj_table = TexturePacks,
    obj_buffer = {},
    required_params = {
        'key',
        'textures'
    },
    class_prefix = 'texpack',
    set = 'Texture Pack',
    process_loc_text = function(self) -- LOC_TXT structure = name = string, text = table of strings
        SMODS.process_loc_text(G.localization.descriptions.texture_packs, self.key, self.loc_txt)
    end,
    inject = function(self)
        if not TexturePacks['default'] then
            local default_textures = {}
            for k,_ in pairs(AltTextures_Utils.selectors) do
                table.insert(default_textures, k)
            end
            TexturePacks['default'] = {
                key = 'default',
                textures = default_textures,
                toggle_textures = {}
            }
            G.localization.descriptions.texture_packs = G.localization.descriptions.texture_packs or {default = {name = 'Base Game', text = {'Base game textures'}}}
        end
        local new_textures = {}
        for _, key in ipairs(self.textures) do
            local temp = {key = key}
            SMODS.modify_key(temp, 'alt_tex', true)
            new_textures[#new_textures + 1] = temp.key
        end
        self.textures = new_textures
        local new_toggles = {}
        for _, key in ipairs(self.toggle_textures or {}) do
            local temp = {key = key}
            SMODS.modify_key(temp, 'alt_tex', true)
            new_toggles[#new_toggles + 1] = temp.key
        end
        self.toggle_textures = new_toggles
        if not Malverk.config.texture_configs then Malverk.config.texture_configs = {} end
        if not Malverk.config.texture_configs[self.key] then
            Malverk.config.texture_configs[self.key] = {}
            for _, key in ipairs(self.textures) do
                Malverk.config.texture_configs[self.key][key] = true
            end
            for _, key in ipairs(self.toggle_textures or {}) do
                Malverk.config.texture_configs[self.key][key] = false
            end
        else
            for _, key in ipairs(self.textures) do
                if type(Malverk.config.texture_configs[self.key][key]) ~= 'boolean' then
                    Malverk.config.texture_configs[self.key][key] = true
                end
            end
            for _, key in ipairs(self.toggle_textures or {}) do
                if type(Malverk.config.texture_configs[self.key][key]) ~= 'boolean' then
                    Malverk.config.texture_configs[self.key][key] = false
                end
            end
        end
        table.insert(TexturePacks_Utils.keys, self.key)
    end
}