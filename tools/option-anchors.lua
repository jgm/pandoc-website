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

  [`-C`, `--change`, `-m`, `--mogrify`]{#option--change}

  :   Change things.

  [`--thing=`*STRING*]{#option--thing}

  :   Specify something
  ```

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
   local inoptions = false
   local newblocks = {}
   for _,b in ipairs(el.blocks) do
      if b.t == 'Header' then
         if contains_value(b.classes, 'options') then
             inoptions = true
         else
             inoptions = false
         end
     end
     if inoptions and b.t == 'DefinitionList' then
         table.insert(newblocks, add_option_anchors(b))
     else
         table.insert(newblocks, b)
     end
 end
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
    return { pandoc.Span(inlines, pandoc.Attr(id)) }
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
