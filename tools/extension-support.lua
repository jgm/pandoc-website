-- Adds format support info to Extension: _____ headings.
--
-- When changing this script you can do a minimal rebuild with:
--
--    make css site/MANUAL.html -B

if FORMAT:match 'html' then
    local ext_to_formats_enabled = {}
    local ext_to_formats_disabled = {}

    for line in io.lines('extension-support.txt') do
        format, enabled, ext = string.match(line, '(.+) (.)(.+)')
        if ext_to_formats_enabled[ext] == nil then
            ext_to_formats_enabled[ext] = {}
        end
        if ext_to_formats_disabled[ext] == nil then
            ext_to_formats_disabled[ext] = {}
        end
        if enabled == '+' then
            table.insert(ext_to_formats_enabled[ext], format)
        else
            table.insert(ext_to_formats_disabled[ext], format)
        end
    end

    local md_extensions_part_of_commonmark = {
        escaped_line_breaks = true,
        space_in_atx_header = true,
        fenced_code_blocks = true,
        backtick_code_blocks = true,
        all_symbols_escapable = true,
        angle_brackets_escapable = true,
        intraword_underscores = true,
        shortcut_reference_links = true,
        lists_without_preceding_blankline = true,
        header_attributes = 'available in commonmark\nvia "attributes" extension',
        fenced_code_attributes = 'available in commonmark\nvia "attributes" extension',
        inline_code_attributes = 'available in commonmark\nvia "attributes" extension',
        link_attributes = 'available in commonmark\nvia "attributes" extension',
    }

    function Header(h)
        local text = pandoc.utils.stringify(h)
        local ext = string.match(text, 'Extension: (.*)')

        if ext == 'superscript, subscript' then
            -- Normalize irregular section name.
            ext = 'superscript'
        elseif ext ~= 'citations %(' then
            ext = 'citations'
        end

        if ext ~= nil then
            local title = ''

            if md_extensions_part_of_commonmark[ext] == true then
                title = title .. 'part of commonmark\n\n'
            elseif md_extensions_part_of_commonmark[ext] then
                title = title .. md_extensions_part_of_commonmark[ext] .. '\n\n'
            end

            if #ext_to_formats_enabled[ext] > 0 then
                title = title .. 'enabled by default for:\n'
                for _, format in pairs(ext_to_formats_enabled[ext]) do
                    title = title .. '+ ' .. format .. '\n'
                end
            end

            if #ext_to_formats_disabled[ext] > 0 then
                if #ext_to_formats_enabled[ext] > 0 then
                    title = title .. '\n'
                end

                title = title .. 'disabled by default for:\n'
                for _, format in pairs(ext_to_formats_disabled[ext]) do
                    title = title .. '- ' .. format .. '\n'
                end
            end

            local checkbox = pandoc.Span(
                {pandoc.Str('±')}, -- content
                { -- attributes
                    class = 'extension-checkbox',
                    ['aria-hidden'] = 'true',
                    title = title,
                }
            )
            h.content:insert(pandoc.Space())
            h.content:insert(checkbox)
            return h
        end
    end
end
