function G.FUNCS.textures_button(e)
	G.SETTINGS.paused = true
    SMODS.save_mod_config(Malverk)
	G.FUNCS.overlay_menu({
		definition = create_UIBox_texture_selection()
	})
end

function G.FUNCS.texture_type(e)
    sendDebugMessage(e.config.id)
end

function create_texture_buttons(current_buttons, page)
    if #current_buttons.nodes > 0 then current_buttons.nodes = {} end
    local total_buttons = 11
    local start_index = 0 + (page * total_buttons) -- page number needs to affect
    for i=1, total_buttons do
        if i+start_index > #AltTextures_Utils.texture_types then break end
        local type = AltTextures_Utils.texture_types[i+start_index]
        local button = UIBox_button({
            button = 'texture_type',
            colour = AltTextures_Utils.selectors[type] and Malverk.badge_colour or G.C.GREY,
            label = {localize('b_'..type)},
            minw = 2.5,
            minh = 0.6,
            scale = 0.35,
            id = type
        })
        if not AltTextures_Utils.selectors[type] then
            button.nodes[1].config.button = nil
            button.nodes[1].config.hover = false
        end
        table.insert(current_buttons.nodes, button)
    end
end

function G.FUNCS.update_buttons(args)
    create_texture_buttons(args.cycle_config.ref_table, 1)
end

function texture_displays(page)
    local rows = 2
    local cols = 6
    
    local output = {n=G.UIT.R, config = {}, nodes = {}}
    for i=1, rows do
        local row = {n=G.UIT.R, config = {padding = 0.1}, nodes = {}}
        for j=1, cols do
            if (cols*(i-1) + j) > #TexturePacks then break end
            local texture_pack = TexturePacks[j + cols*(i-1)]
            local node = {n=G.UIT.C, config = {minw=2, minh = 2.5, r=0.1, colour = G.C.BLUE}}
            table.insert(row.nodes, node)
        end
        table.insert(output.nodes, row)
    end

    return output
end

function create_UIBox_texture_selection()
    Malverk:update_atlas()
    Malverk.texture_pack_priority_area = CardArea(G.ROOM.T.w, G.ROOM.T.h, 11, G.CARD_H, 
    {type = 'joker', highlight_limit = 1, deck_height = 0.75, thin_draw = 1, texture_priority = true})
    Malverk.texture_pack_priority_area.ARGS.invisible_area_types = {joker=1}
    for _, texture_pack in ipairs(Malverk.config.selected) do
        if TexturePacks[texture_pack] then
            local card = create_texture_card(Malverk.texture_pack_priority_area, texture_pack)
            card.params.texture_priority = true
            Malverk.texture_pack_priority_area:emplace(card)
        end
    end
    
    generate_texture_pack_areas()
    local t = create_UIBox_generic_options({ back_func = 'options', contents = {
        {n=G.UIT.R, config = {colour = G.C.CLEAR, align = 'cm', minw = 12, minh = 10}, nodes = {
            {n=G.UIT.C, config={align = "cm", padding = 0.15, r = 0.1, minw = 12}, nodes={
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 2.5, minw = 12, align = 'cm'}, nodes = {
                    {n=G.UIT.C, config = {align = 'cm', padding = 0.1, minw = 0.5}, nodes = {{n=G.UIT.T, config = {text = localize('malverk_low'), scale = 0.5, vert = true, colour = G.C.L_BLACK}}}},
                    {n=G.UIT.C, config = {align = 'cm', minw = 11}, nodes = {
                        -- {n=G.UIT.T, config = {text = 'priority card area', scale = 0.7, colour = G.C.WHITE}}
                        {n = G.UIT.O, config = {object = Malverk.texture_pack_priority_area, colour = G.C.BLUE}}
                    }},
                    {n=G.UIT.C, config = {align = 'cm', padding = 0.1, minw = 0.5}, nodes = {{n=G.UIT.T, config = {instance_type = 'UIBOX', text = localize('malverk_high'), scale = 0.5, vert = true, colour = G.C.L_BLACK}}}},
                }},
                -- Main Texture Select Display
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 7.5, minw = 12, align = 'tm'}, nodes = {
                    generate_texture_pack_areas_ui(),
                    -- Page cycler
                    {n=G.UIT.R, config = {align = 'lm'}, nodes ={
                        EremelUtility.page_cycler({
                            object_table = TexturePacks,
                            page_size = 10,
                            key = 'texture_pack_selector',
                            switch_func = Malverk.new_change_page
                        })
                    }},
                }},
            }},
        }}
    }})
    return t

end

Malverk.new_change_page = function(pages)
    alt_text_clean_up()
    populate_texture_select_areas(pages.to)
end

function create_UIBox_texture_selection_advanced()
    local buttons = {n = G.UIT.R, config = {align = 'tm', minh = 8, padding = 0.1}, nodes = {}}
    create_texture_buttons(buttons, 0)

    local t = create_UIBox_generic_options({ back_func = 'options', contents = {
        {n=G.UIT.R, config = {colour = G.C.CLEAR, align = 'cm', minw = 15, minh = 10}, nodes = {

            {n=G.UIT.C, config={align = "tm", padding = 0.15, r = 0.1, colour = G.C.BLACK, minw = 3, minh = 10}, nodes={
                {n=G.UIT.R, config = {align = 'cm', colour = G.C.CLEAR}, nodes = {
                    {n=G.UIT.T, config = {text = 'Types', scale = 0.5, colour = G.C.L_BLACK}},
                }},
                {n=G.UIT.R, config = {minh = 0.025, r = 0.1, colour = G.C.L_BLACK}},
                buttons,
                {n=G.UIT.R, nodes = {
                    create_option_cycle({options = {'Page 1/2','Page 2/2'}, opt_callback = 'update_buttons', ref_table = buttons, no_pips = true, current_option = 1, colour = G.C.BLUE, w = 2, scale = 0.8, text_scale = 0.35/0.8})
                }}
            }},
            {n=G.UIT.C, config={align = "cm", padding = 0.15, r = 0.1, minw = 12}, nodes={
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 2.5, minw = 12, align = 'cm'}, nodes = {
                    {n=G.UIT.C, config = {align = 'cm', padding = 0.1, minw = 0.5}, nodes = {{n=G.UIT.T, config = {text = 'LOWEST', scale = 0.5, vert = true, colour = G.C.L_BLACK}}}},
                    {n=G.UIT.C, config = {align = 'cm', minw = 11}, nodes = {{n=G.UIT.T, config = {text = 'priority card area', scale = 0.7, colour = G.C.WHITE}}}},
                    {n=G.UIT.C, config = {align = 'cm', padding = 0.1, minw = 0.5}, nodes = {{n=G.UIT.T, config = {text = 'HIGHEST', scale = 0.5, vert = true, colour = G.C.L_BLACK}}}},
                }},
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 7.5, minw = 12, align = 'cm'}, nodes = {
                    {n=G.UIT.T, config = {text = 'texture displays', scale = 1, colour = G.C.WHITE}}
                }},
            }},
        }}
    }})
    return t
end


function generate_texture_pack_areas()
    if Malverk.texture_pack_areas then
        for i=1, #Malverk.texture_pack_areas do
            for j=1, #G.I.CARDAREA do
                if Malverk.texture_pack_areas[i] == G.I.CARDAREA[j] then
                    table.remove(G.I.CARDAREA, j)
                    Malverk.texture_pack_areas[i] = nil
                end
            end
        end
    end
    Malverk.texture_pack_areas = {}
    Malverk.texture_pack_areas_page = {
        page = 1,
        total = math.ceil(table.size(TexturePacks)/10),
    }
    Malverk.texture_pack_areas_page.text = localize('k_page')..' '..(Malverk.texture_pack_areas_page.page+1)..'/'..Malverk.texture_pack_areas_page.total
    for i=1, 10 do
        Malverk.texture_pack_areas[i] = CardArea(G.ROOM.T.w,G.ROOM.T.h, G.CARD_W, G.CARD_H, 
        {card_limit = 1, type = 'shop', highlight_limit = 1, deck_height = 0.75, thin_draw = 1, texture_pack = true, index = i})
    end
end

function table.size(table)
    local size = 0
    for _,_ in pairs(table) do
        size = size + 1
    end
    return size
end

function generate_texture_pack_areas_ui()
    local texture_ui_element = {}
    local count = 1
    for i=1, 2 do
        local row = {n = G.UIT.R, config = {colour = G.C.CLEAR}, nodes = {}}
        for j=1, 5 do
            if count > table.size(TexturePacks) then break end
            table.insert(row.nodes, {n = G.UIT.O, config = {object = Malverk.texture_pack_areas[count], r = 0.1, id = "texture_pack_"..count}})
            count = count + 1
        end
        table.insert(texture_ui_element, row)
    end

    populate_texture_select_areas(Malverk.texture_pack_areas_page.page)

    return {n=G.UIT.R, config={align = "tm", minh = 6.3, minw = 5, colour = G.C.CLEAR,
        padding = 0.15, r = 0.1, emboss = 0.05}, nodes = texture_ui_element}
end

function populate_texture_select_areas(page)
    local count = 1 + (page-1) * 10
    for i=1, 10 do
        if count > table.size(TexturePacks) then return end
        local card = create_texture_card(Malverk.texture_pack_areas[i], TexturePacks_Utils.keys[count])
        for _, texture in ipairs(Malverk.config.selected) do
            if texture == TexturePacks_Utils.keys[count] then card.texture_selected = true end
        end
        if not Malverk.texture_pack_areas[i].cards then Malverk.texture_pack_areas[i].cards = {} end
        Malverk.texture_pack_areas[i]:emplace(card)
        count = count + 1
    end
end

local card_hover_ref = Card.hover
function Card:hover()
    if self.params.texture_pack and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui and not G.debug_tooltip_toggle then
        self:juice_up(0.05, 0.03)
        play_sound('paper1', math.random()*0.2 + 0.9, 0.35)
        if self.children.alert and not self.config.center.alerted then
            self.config.center.alerted = true
            G:save_progress()
        end

        local col = self.params.deck_preview and G.UIT.C or G.UIT.R
        local info_col = self.params.deck_preview and G.UIT.R or G.UIT.C
        local back = Back(self.config.center)

        local badges = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes = {}}
        SMODS.create_mod_badges(TexturePacks[self.params.texture_pack], badges.nodes)
        if badges.nodes.mod_set then badges.nodes.mod_set = nil end

        local loc_txt = {}
        localize({type='descriptions', set = 'texture_packs', key = self.params.texture_pack, nodes = loc_txt})
        local desc_node = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes = {desc_from_rows(loc_txt, true)}}
        
        local changes
        if self.params.texture_pack ~= 'default' then
            changes = {n=G.UIT.ROOT, config = {colour = G.C.CLEAR, align = 'cm'}, nodes ={}}
            local objects = {}
            for _, texture in pairs(TexturePacks[self.params.texture_pack].textures) do
                local set = AltTextures[texture].set
                -- if set == 'Enhanced' then set = 'Enhancement' end
                local count = #AltTextures[texture].keys
                objects[set] = (objects[set] or 0) + count
            end
            for set, count in pairs(objects) do
                local text_node = {n=G.UIT.R, nodes = {
                    {n=G.UIT.C, nodes = {{n=G.UIT.T, config = {text = localize('b_change')..' '..count..' ', scale = 0.28*G.LANG.font.DESCSCALE, colour = G.C.UI.TEXT_DARK}}}},
                    {n=G.UIT.C, nodes = {{n=G.UIT.T, config = {text = localize(AltTextures_Utils.loc_keys[set]), scale = 0.28*G.LANG.font.DESCSCALE, colour = G.C.SECONDARY_SET[set] or G.C.IMPORTANT}}}},
                }}
                changes.nodes[#changes.nodes + 1] = text_node
            end
        end

        self.config.h_popup = {n=G.UIT.C, config={align = "cm", padding=0.1}, nodes={
            {n=col, config={align=(self.params.deck_preview and 'bm' or 'cm')}, nodes = {
                {n=G.UIT.C, config={align = "cm", minh = 1.5, r = 0.1, colour = G.C.L_BLACK, padding = 0.1, outline=1}, nodes={
                    -- Name
                    {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={
                        {n=G.UIT.O, config={object = UIBox{
                            definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                                {n=G.UIT.O, config={object = DynaText({string = localize({type = 'name_text', set = 'texture_packs', key = self.params.texture_pack}), maxw = 4, colours = {G.C.WHITE}, shadow = true, bump = true, scale = 0.5, pop_in = 0, silent = true})}},
                            }},
                            config = {offset = {x=0,y=0}, align = 'cm', parent = e}}}
                        },
                    }},
                    -- Description Text
                    {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.3, maxh = 3, minw = 3, maxw = 4, r = 0.1}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = desc_node, config = {offset = {x=0,y=0}}}}}
                    }},
                    -- TODO: Add box detailing number of changes
                    changes and {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.3, minw = 3, maxw = 4, r = 0.1, padding = 0.2}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = changes, config = {offset = {x=0,y=0}}}}}
                    }},
                    -- Badges
                    badges.nodes[1] and {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = badges, config = {offset = {x=0,y=0}}}}}
                    }},
                }}
            }},
            
        }}
        self.config.h_popup_config = self:align_h_popup()

        Node.hover(self)
    else
       card_hover_ref(self) 
    end
end

local card_highlight = Card.highlight
function Card:highlight(highlighted)
    if self.params.texture_priority then 
        self.highlighted = highlighted
        if highlighted then
            self.children.use_button = UIBox{
                definition = create_texture_pack_buttons(self), 
                config = {align = 'cm', offset = {x=0, y=0.4}, parent = self}
            }
        end
        return
    end
    card_highlight(self, highlighted)
    if highlighted and self.area and self.area.config.texture_pack then
        self.children.use_button = UIBox{
            definition = create_texture_pack_buttons(self, self.texture_selected), 
            config = {align = 'cm', offset = {x=0, y=0.4}, parent = self}
        }
    end
end

local applied_shader = SMODS.Shader({key = 'texture_selected', path = 'applied.fs'})
local settings_atlas = SMODS.Atlas{key = 'settings', path = 'settings.png', px = 32, py = 32}
function create_texture_pack_buttons(card, active)
    local apply
    local config = {n=G.UIT.R, config={minh = 0.55}}
    local spacer = {n=G.UIT.R, config={minh = 0.8}}
    if card.area.config.type == 'joker' then
        apply = {n=G.UIT.R, config={align = 'cm'}, nodes={
            {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.C, config={ref_table = card, align = "bm", maxw = G.CARD_W * 0.5, shadow = true, padding = 0.1, r=0.08, minw = 0.5 * G.CARD_W, minh = 0.8, hover = true, colour = G.C.RED, button = 'remove_texture'}, nodes={
                    {n=G.UIT.T, config={text = localize('b_remove'), colour = G.C.UI.TEXT_LIGHT, scale = 0.35, shadow = true}}
                }}
            }}
        }}
        config = {n=G.UIT.R, config={minh = 1.45}}
        spacer = {n=G.UIT.R, config={minh = 0.65}}
        if #TexturePacks[card.params.texture_pack].textures + (TexturePacks[card.params.texture_pack].toggle_textures and #TexturePacks[card.params.texture_pack].toggle_textures) > 1 then 
            local settings_sprite = Sprite(0, 0, 0.5, 0.5, G.ASSET_ATLAS['malverk_settings'] ,{x=0, y=0})
            config = {n=G.UIT.R, config={align = 'cr', minw = 1.6*G.CARD_W}, nodes={
                {n=G.UIT.R, config={minh = 0.65}},
                {n=G.UIT.R, nodes = {
                    {n=G.UIT.C, config={minw = G.CARD_W, minh = 0.8, colour = G.C.IMPORTANT, r = 0.1, align = 'cr', shadow = true, padding = 0.1, hover = true, button = 'texture_config', ref_table = card.params}, nodes = {
                        {n=G.UIT.O, config={can_collide = false, object = settings_sprite, shadow = true}}
                    }}
                }}
            }}
            spacer = {n=G.UIT.R, config={minh = 0.65}}
        end
    else
        apply = {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.C, config={ref_table = card, align = "bm", maxw = G.CARD_W * 0.5, shadow = true, padding = 0.1, r=0.08, minw = 0.5 * G.CARD_W, minh = 0.8, hover = true, colour = active and G.C.GREY or G.C.GREEN, button = not active and 'apply_texture'}, nodes={
                    {n=G.UIT.T, config={text = active and localize('b_applied') or localize('b_apply'), colour = G.C.UI.TEXT_LIGHT, scale = 0.35, shadow = true}}
                }}
            }}       
    end
    local t = {n=G.UIT.ROOT, config = {align = 'cm', padding = 0, colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config={align = 'cm'}, nodes={
            config,
            spacer,
            apply
        }},
    }}
    return t
end

G.FUNCS.texture_config = function(e)
	G.FUNCS.overlay_menu({
		definition = create_UIBox_texture_config(e.config.ref_table.texture_pack)
	})
end

function create_UIBox_texture_config(texture)
    local label = {text = 'Page 1'}
    
    local t = create_UIBox_generic_options({ back_func = 'textures_button', contents = {
        {n=G.UIT.R, config = {colour = G.C.CLEAR, align = 'cm', minw = 12}, nodes = {
            {n=G.UIT.C, config={align = "cm", padding = 0.15, r = 0.1, minw = 12}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR, r = 0.1, padding = 0.2}, nodes={
                    {n=G.UIT.T, config = {text = 'Configuring', scale = 0.8, colour = G.C.WHITE, shadow = true}},
                    {n=G.UIT.T, config = {text = localize({type = 'name_text', set = 'texture_packs', key = texture}), scale = 0.8, colour = G.C.WHITE, shadow = true}}
                }},
                -- Main Texture Select Display
                {n=G.UIT.R, config = {colour = G.C.BLACK, r = 0.1, minh = 7.5, minw = 12, align = 'tm', padding = 0.5}, nodes = {
                    {n=G.UIT.R, config = {align = 'tl'}, nodes ={
                        Malverk.texture_config_toggles(texture)
                    }},
                    -- Page cycler
                    {n=G.UIT.R, config = {align = 'cm'}, nodes ={
                        EremelUtility.page_cycler({
                            object_table = Malverk.config.texture_configs[texture],
                            page_size = 18,
                            key = 'texture'
                        })
                    }},
                }},
            }},
        }}
    }})
    return t
end

Malverk.texture_config_toggles = function(texture)
    local toggles = {n=G.UIT.R, config = {align = 'tm'}, nodes = {
        {n=G.UIT.C, config = {align = 'tl'}, nodes = {}},
        {n=G.UIT.C, config = {align = 'tl'}, nodes = {}},
    }}
    local textures = SMODS.merge_lists({TexturePacks[texture].textures, TexturePacks[texture].toggle_textures})
        for i=#textures, 1, -1 do
            local current_toggle = EremelUtility.create_toggle({
                label = localize({type = 'name_text', set = 'alt_texture', key = textures[i]}),
                ref_table = Malverk.config.texture_configs[texture],
                ref_value = textures[i],
                left = false,
            })
            if i < 10 then 
                toggles.nodes[1].nodes[#toggles.nodes[1].nodes + 1] = current_toggle
            else
                toggles.nodes[2].nodes[#toggles.nodes[2].nodes + 1] = current_toggle
            end
        end
    return toggles
end

G.FUNCS.remove_texture = function(e)
    local texture = e.config.ref_table.params.texture_pack
    e.config.ref_table:highlight()
    e.config.ref_table:start_dissolve()
    for _, area in pairs(Malverk.texture_pack_areas) do
        if #area.cards > 0 and area.cards[1].params.texture_pack == texture then
            area.cards[1].texture_selected = false
            area.cards[1]:highlight()
            area.cards[1]:juice_up()
        end
    end
    Malverk.update_priority(texture)
end

G.FUNCS.apply_texture = function(e)
    if e.config.ref_table.texture_selected then
        e.config.ref_table.texture_selected = false
        e.config.ref_table:juice_up()
    else
        e.config.ref_table.texture_selected = true
        e.config.ref_table:juice_up()
        e.config.ref_table:highlight()
        local card = create_texture_card(Malverk.texture_pack_priority_area, e.config.ref_table.params.texture_pack)
        card.params.texture_priority = true
        Malverk.texture_pack_priority_area:emplace(card)
        Malverk.update_priority()
    end
end

G.FUNCS.malverk_change_page = function(e)
    Malverk.change_page(Malverk.texture_pack_areas_page, e.config.direction)
end

Malverk.change_page = function(page_ref, change)
    page_ref.page = page_ref.page + change
    page_ref.page = page_ref.page % page_ref.total
    page_ref.text = 'Page '..(page_ref.page+1)..'/'..page_ref.total
    alt_text_clean_up()
    populate_texture_select_areas(page_ref.page)
end

alt_text_clean_up = function()
    if not Malverk.texture_pack_areas then return end
    for j = 1, #Malverk.texture_pack_areas do
        if Malverk.texture_pack_areas[j].cards then
            remove_all(Malverk.texture_pack_areas[j].cards)
            Malverk.texture_pack_areas[j].cards = {}
        end
    end
end

function create_texture_card(area, texture_pack)
    local texture = AltTextures[TexturePacks[texture_pack].textures[1]]
    if TexturePacks[texture_pack].dynamic_display and Malverk.config.texture_configs[texture_pack] then
        local textures = SMODS.merge_lists({TexturePacks[texture_pack].textures, TexturePacks[texture_pack].toggle_textures})
        local i = 1
        while (not Malverk.config.texture_configs[texture_pack][textures[i]]) and i < #textures do
            i = i + 1
            if AltTextures[textures[i]].display_pos then texture = AltTextures[textures[i]] end
        end
    end
    local card = Card(area.T.x, area.T.y, G.CARD_W, G.CARD_H,
        nil, copy_table(G.P_CENTERS.j_joker),
        {texture_pack = texture_pack})
    
    local layer = texture.animated and 'animatedSprite' or texture.set == 'Sticker' and 'front' or 'center'    
    local game_table = AltTextures_Utils.game_table[texture.set] or 'P_CENTERS'
    local scale = math.max(texture.atlas.px/71, texture.atlas.py/95)
    if scale < 1 then scale = scale * 1.5 end
    local W = G.CARD_W*(texture.atlas.px/71)/scale
    local H = G.CARD_H*(texture.atlas.py/95)/scale
    

    if texture.animated then
        card.T.w = W
        card.T.h = H
        card.children.animatedSprite = AnimatedSprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ANIMATION_ATLAS[texture.atlas.key], type(texture.display_pos) == 'table' and texture.display_pos or (texture.display_pos and (texture.original_sheet and G[game_table][texture.display_pos].default_pos or G[game_table][texture.display_pos].pos)) or G[game_table][texture.keys[1]].pos)
        card.children.animatedSprite.T.w = W
        card.children.animatedSprite.T.h = H
        card.children.animatedSprite:set_role({major = card, role_type = 'Glued', draw_major = card})
        card.children.animatedSprite:rescale()
        card.children.center:remove()
        card.children.back:remove()
        card.no_shadow = true
        return card
    end

    if layer == 'front' and not card.children[layer] then
        card.children.center.atlas.name = 'centers'
        card.children.center.sprite_pos = {x=1,y=0}
        card.children.center:reset()
        card.children[layer] = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[texture.atlas.key], G[game_table][texture.keys[1]].pos)
        card.children[layer].states.hover = card.states.hover
        card.children[layer].states.click = card.states.click
        card.children[layer].states.drag = card.states.drag
        card.children[layer].states.collide.can = false
        card.children[layer]:set_role({major = card, role_type = 'Glued', draw_major = card})
    end
    
    if texture_pack ~= 'default' then
        local atlas_copy =  {}
        for k, v in pairs(card.children[layer].atlas) do
            atlas_copy[k] = v
        end
        card.children[layer].atlas = atlas_copy
        card.children[layer].atlas.name = texture.atlas.key
    else
        card.children[layer].atlas.name = 'Joker'
    end
    
    if texture.original_sheet and texture.keys and texture_pack ~= 'default' then
        card.children[layer].sprite_pos = G[game_table][texture.keys[1]].default_pos or G[game_table][texture.keys[1]].pos
    end
    
    if texture.display_pos and texture_pack ~= 'default' then
        card.children[layer].sprite_pos = type(texture.display_pos) == 'table' and texture.display_pos or (texture.original_sheet and G[game_table][texture.display_pos].default_pos or Malverk.get_pos_on_sheet(texture.display_pos, texture))
    end
    
    card.children[layer]:reset()

    if texture.animated and texture_pack ~= 'default' then return card end

    if texture.atlas.px ~= 71 and texture.atlas.py ~= 95 and not texture.animated and texture_pack ~= 'default' then
        card.T.w = W
        card.T.h = H
        card.children[layer] = Sprite(card.T.x, card.T.y, G.CARD_W, G.CARD_H, G.ASSET_ATLAS[texture.atlas.key], card.children.center.sprite_pos)
        card.children[layer].states.hover = card.states.hover
        card.children[layer].states.click = card.states.click
        card.children[layer].states.drag = card.states.drag
        card.children[layer].states.collide.can = false
        card.children[layer]:set_role({major = card, role_type = 'Glued', draw_major = card})
    end

    if texture.soul_keys and table.contains(texture.soul_keys, texture.keys[1]) and texture_pack ~= 'default' then
        card.config[layer].soul_pos = {x = 1 % texture.columns, y = math.floor(1/texture.columns)}
        card.children.floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[texture.atlas.key], card.config[layer].soul_pos)
    end
        
    return card
end

local release_ref = Node.stop_drag
function Node:stop_drag()
    release_ref(self)
    if self.params and self.params.texture_priority then
        Malverk.update_priority()
    end
end

function Malverk.update_priority(removed_key)
    Malverk.config.selected = {}
    for _, card in ipairs(Malverk.texture_pack_priority_area.cards) do
        if card.params.texture_pack ~= removed_key then
            Malverk.config.selected[#Malverk.config.selected + 1] = card.params.texture_pack
        end
    end
    Malverk.update_atlas()
    SMODS.save_mod_config(Malverk)
end

local align_ref = CardArea.align_cards
function CardArea:align_cards()
    if self.config.texture_pack then
        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then 
                card.T.r = 0
                local max_cards = math.max(#self.cards, self.config.temp_limit)
                card.T.x = self.T.x + self.T.w/2 - card.T.w/2
                local highlight_height = G.HIGHLIGHT_H
                if not card.highlighted then highlight_height = 0 end
                card.T.y = self.T.y + self.T.h/2 - card.T.h/2 - highlight_height
                card.T.x = card.T.x + card.shadow_parrallax.x/30
            end
        end
        table.sort(self.cards, function (a, b) return a.T.x + a.T.w/2 < b.T.x + b.T.w/2 end)
    else
        align_ref(self)
    end
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

function Malverk.get_pos_on_sheet(key, texture)
    if texture.original_sheet then return false end
    local place = 0
    for i, tex_key in ipairs(texture.keys) do
        if tex_key == key then place = i end
    end
    return {x = (place-1) % texture.columns, y = math.floor((place-1)/texture.columns)}
end
EremelUtility = {}
EremelUtility.page_cycler_values = {}

G.FUNCS.eremel_default = function(e)
    local args = e.config.pass_through
    local page_from = EremelUtility.page_cycler_values[args.key].page
    local page_to = EremelUtility.page_cycler_values[args.key].page + e.config.direction
    if page_to == 0 then page_to = args.total_pages
    elseif page_to > args.total_pages then page_to = 1 end
    EremelUtility.page_cycler_values[args.key].page = page_to
    EremelUtility.page_cycler_values[args.key].text = localize('k_page')..' '..EremelUtility.page_cycler_values[args.key].page..'/'..args.total_pages
    
    
    if e.config.switch_func and type(e.config.switch_func) == 'function' then
        e.config.switch_func({from = page_from, to = page_to})
    else
        sendInfoMessage('No switch_func provided', 'EremelUtility')
        sendInfoMessage(tprint({from = page_from, to = page_to}), 'EremelUtility')
    end
end

function EremelUtility.page_cycler(args)
    args = args or {}
    args.left = args.left or '<'
    args.right = args.right or '>'
    args.colour = args.colour or Malverk.badge_colour
    args.button_colour = args.button_colour or G.C.WHITE
    args.button = args.button or 'eremel_default'
    args.switch_func = args.switch_func
    args.hover = args.hover or true
    args.object_table = args.object_table -- REQUIRED
    args.page_size = args.page_size -- REQUIRED
    args.page_label = args.page_label -- REQUIRED
    args.label_colour = args.label_colour or G.C.WHITE
    args.scale = args.scale or 0.5
    args.button_w = args.button_w or 3
    args.w = args.w or 8
    args.shadow = args.shadow or true

    local error = {n=G.UIT.C, config = {r=0.1, colour = G.C.RED, align = 'cm', padding = 0.1}, nodes = {}}
    if not args.key then
        error.nodes[#error.nodes + 1] = {n=G.UIT.R, nodes = {{n=G.UIT.T, config = {text = 'Page Cycler missing key', scale = args.scale, colour = G.C.BLACK, shadow = true}}}}
    end
    if not args.object_table then
        error.nodes[#error.nodes + 1] = {n=G.UIT.R, nodes = {{n=G.UIT.T, config = {text = 'Page Cycler missing object_table', scale = args.scale, colour = G.C.BLACK, shadow = true}}}}
    end
    if not args.page_size then
        error.nodes[#error.nodes + 1] = {n=G.UIT.R, nodes = {{n=G.UIT.T, config = {text = 'Page Cycler missing page_size', scale = args.scale, colour = G.C.BLACK, shadow = true}}}}
    end
    
    if #error.nodes > 0 then return error end
    
    args.total_pages = math.ceil(table.size(args.object_table)/args.page_size)

    if not args.page_label then
        EremelUtility.page_cycler_values[args.key] = {page = 1}
        EremelUtility.page_cycler_values[args.key].text = localize('k_page')..' '..EremelUtility.page_cycler_values[args.key].page..'/'..args.total_pages
        args.page_label = EremelUtility.page_cycler_values[args.key]
    end 

    local cycler = {n=G.UIT.R, config = {align = 'cm', minh = args.h or nil}, nodes = {
        table.size(args.object_table) > args.page_size and {n=G.UIT.C, config={pass_through = args, switch_func = args.switch_func, r = 0.1, colour = args.colour, minw = args.button_w * args.scale, align = 'tm', shadow = args.shadow, direction = -1, button = args.button, hover = args.hover, minh = 0.5}, nodes = {
            {n=G.UIT.T, config = {text = args.left, scale = args.scale, colour = args.button_colour}}
        }} or nil,
        table.size(args.object_table) > args.page_size and {n=G.UIT.C, config = {align = 'cm', minw = args.w * args.scale}, nodes = {
            {n=G.UIT.O, config = {object = DynaText({
                string = {{ref_table = args.page_label, ref_value = 'text'}},
                scale = args.scale,
                colours = {args.label_colour},
                pop_in_rate = 0,
                silent = true
            })}}
        }} or nil,
        table.size(args.object_table) > args.page_size and {n=G.UIT.C, config={pass_through = args, switch_func = args.switch_func, r = 0.1, colour = args.colour, minw = args.button_w * args.scale, align = 'tm', shadow = args.shadow, direction = 1, button = args.button, hover = args.hover, minh = 0.5}, nodes = {
            {n=G.UIT.T, config = {text = args.right, scale = args.scale, colour = args.button_colour}}
        }} or nil,
    }}

    return cycler
end

function EremelUtility.create_toggle(args)
    args = args or {}
    args.active_colour = args.active_colour or Malverk.badge_colour
    args.inactive_colour = args.inactive_colour or G.C.BLACK
    args.w = args.w or 3
    args.h = args.h or 0.5
    args.scale = args.scale or 1
    args.label = args.label or 'TEST?'
    args.label_scale = args.label_scale or 0.4
    args.ref_table = args.ref_table or {}
    args.ref_value = args.ref_value or 'test'
    args.left = args.left or false
    args.right = args.right or true
    args.info_above = args.info_above or false

    local error = {n=G.UIT.C, config = {r=0.1, colour = G.C.RED, align = 'cm', padding = 0.1}, nodes = {}}

    if args.left and args.right then
        error.nodes[#error.nodes + 1] = {n=G.UIT.R, nodes = {{n=G.UIT.T, config = {text = 'Left and Right selected', scale = args.scale, colour = G.C.BLACK, shadow = true}}}}
    end

    if #error.nodes > 0 then return error end

    local check = Sprite(0,0,0.5*args.scale,0.5*args.scale,G.ASSET_ATLAS["icons"], {x=1, y=0})
    check.states.drag.can = false
    check.states.visible = false

    local info = nil
    if args.info then 
        info = {}
        for k, v in ipairs(args.info) do 
            table.insert(info, {n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes={
            {n=G.UIT.T, config={text = v, scale = 0.25, colour = G.C.UI.TEXT_LIGHT}}
            }})
        end
        info =  {n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes=info}
    end

    local toggle = {n=G.UIT.C, config = {align = 'cm', minw = 0.3*args.w}, nodes = {
        {n=G.UIT.C, config = {align = 'cm', r=0.1, colour = G.C.BLACK}, nodes={
            {n=G.UIT.C, config={align = "cm", r = 0.1, padding = 0.03, minw = 0.4*args.scale, minh = 0.4*args.scale, outline_colour = args.outline or G.C.WHITE, outline = 1.2*args.scale, line_emboss = 0.5*args.scale, ref_table = args,
                colour = args.inactive_colour,
                button = 'toggle_button', button_dist = 0.2, hover = true, toggle_callback = args.callback, func = 'toggle', focus_args = {funnel_to = true}}, nodes={
                {n=G.UIT.O, config={object = check}},
            }}
        }}
    }}

    local label = {n=G.UIT.C, config={align = args.left and 'cr' or 'cl', minw = args.w}, nodes={
        {n=G.UIT.T, config={text = args.label, scale = args.label_scale, colour = G.C.UI.TEXT_LIGHT}},
        {n=G.UIT.B, config={w = 0.1, h = 0.1}},
    }}

    local t = 
        {n=args.col and G.UIT.C or G.UIT.R, config={align = args.left and 'cr' or 'cl', padding = 0.1, r = 0.1, colour = G.C.CLEAR, focus_args = {funnel_from = true}}, nodes={
            args.left and label or nil,
            toggle,
            args.right and label or nil
        }}

    if args.info then 
        t = {n=args.col and G.UIT.C or G.UIT.R, config={align = "cm"}, nodes={
        args.info_above and info or nil,
        t,
        args.info_above and nil or info,
        }}
    end
    return t
end
