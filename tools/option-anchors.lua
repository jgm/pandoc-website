--[[
  pandoc option-anchors.lua

  This filter finds definition lists that occur directly under
  a header with class `option` (that is, not under a subheader
  under such a class, and not inside a block container like
  a div or a block quote), and adds spans with identifiers to definition
  terms that seem to contain options.  The options are assumed
  to be in code spans and to start with `--`.  The identifiers
  are composed of the word `option` followed by the first long
  option (including initial hyphens).

  Example:

  ```
  ## General options {.options}

  `-C`, `--change`, `-m`, `--mogrify`

  :   Change things.

  `--thing=`*STRING*

  :   Specify something
  ```

  becomes

  ```
  ## General options {.options}

  [`-C`, `--change`, `-m`, `--mogrify`]{#option--change .option-anchor}

  :   Change things.

  [`--thing=`*STRING*]{#option--thing}

  :   Specify something
  ```

  Additionally Code elements inside a Span element with class
  `.option-anchor` which start with what looks like an option
  name receive class `.option-def` (i.e. the above should really
  say `` `-C`{.option-def} `` etc.!) and Code elements *elsewhere*
  which start with what looks like an option name are wrapped in
  a link to the correspondin option definition with class `.option`,
  e.g.  `` [`-m`](#option--change){.option} `` *if* the option-name-like
  prefix coincides with an option name which occurs in an option
  definition.  The purpose of the `.option` class is so that the
  code element inside the link can be styled to look similar to
  other links in the document rather than like "plain" code, e.g.
  with a CSS rule like `a.option code { color: inherit; }`.
  (Added by BPJ, 1 March 2019.)


  Authors: Benct Philip Jonsson <bpjonsson@gmail.com>,
           John MacFarlane <jgm@berkeley.edu>.
]]

local stringify = pandoc.utils.stringify

local function contains_value(tab, val)
   for index, value in ipairs(tab) do
      if value == val then
         return true
      end
   end
   return false
end

function Pandoc(el)
    local inoptions  = false
    local newblocks  = {}
    local opt_id_map = {}
    for _,b in ipairs(el.blocks) do
        if b.t == 'Header' then
            if contains_value(b.classes, 'options') then
                inoptions = true
            else
                inoptions = false
            end
        end
        if inoptions and b.t == 'DefinitionList' then
            local dl = add_option_anchors(b)
            dl = collect_option_ids(dl, opt_id_map)
            table.insert(newblocks, dl)
        else
            table.insert(newblocks, b)
        end
    end
    newblocks = add_option_links(newblocks, opt_id_map)
    return pandoc.Pandoc(newblocks, el.meta)
end

local function get_option_id (ils)
    for _,il in ipairs(ils) do
        if il.t == 'Code' and string.find(il.text, '^%-%-') then
            return ('option' .. il.text:gsub('=.*',''))
         end
    end
   return nil
end

local function span_with_id (inlines, id)
    if #inlines < 1 then return {} end
    if #inlines == 1 then
        if inlines[1].t == 'Span' then
            local span = inlines[1]
            local old_id = span.identifier or ""
            if old_id == id then return span end
            if string.len(old_id) == 0 then
                span.identifier = id
                return { span }
            end
        end
    end
    return { pandoc.Span(inlines, pandoc.Attr(id, {'option-anchor'})) }
end

function add_option_anchors(el)
   for _,df in ipairs(el.content) do
      local id = get_option_id(df[1])
      if id ~= nil then
         df[1] = span_with_id(df[1], id)
      end
   end
   return el
end

function collect_option_ids(el, opt_id_map)
    opt_id_map = opt_id_map or {}
    local id
    local code_filter = { Code = function (code)
            local opt_name = string.match(code.text, '^%-[%-%w]+')
            if opt_name then
                opt_id_map[opt_name] = id
                table.insert(code.attr.classes, 'option-def')
                return code
            else
                return nil
            end
        end
    }
    local span_filter = { Span = function (span)
            if contains_value(span.classes, 'option-anchor') then
                id = '#' .. span.identifier
                span = pandoc.walk_inline(span, code_filter)
                return span
            else
                return nil
            end
        end
    }
    return pandoc.walk_block(el, span_filter)
end

function add_option_links(blocks, opt_id_map)
    return pandoc.walk_block(pandoc.Div(blocks), { Code = function (el)
            local opt_name = string.match(el.text, '^%-[%-%w]+')
            if opt_name then
                local id = opt_id_map[opt_name]
                if id then
                    if contains_value(el.classes, 'option-def') then
                        return nil
                    else
                        return pandoc.Link({el}, id, "", pandoc.Attr("", {'option'}))
                    end
                else
                    return nil
                end
            end
        end
    }).content
end
