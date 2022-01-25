local function makecard(ident, bs)
  local headb = bs[1]
  table.remove(bs, 1)
  local body = pandoc.Div(bs, pandoc.Attr("", {"card-body"}))
  local head = pandoc.Div({headb}, pandoc.Attr("", {"card-header"}))
  return pandoc.Div(
            { head
            , pandoc.Div(body, pandoc.Attr("collapse-" .. ident,
                {"collapse"}))
            },
            pandoc.Attr(ident, {"section","card"}))
end

function Div(el)
  if el.classes[1] == "faqs" then
    local chunks = {}
    local nextchunk = {}
    local ident = ""
    local seen_header = false
    for _,b in ipairs(el.content) do
      if b.t == 'Header' then
        seen_header = true
        if #nextchunk > 0 then
          chunks[#chunks + 1] = makecard(ident, nextchunk)
        end
        ident = b.identifier -- string.gsub(b.identifier, "%p+", "-")
        -- b.identifier = ""
        -- b.level = 4
        nextchunk = {pandoc.Para(b.content)}
      elseif seen_header then
        table.insert(nextchunk, b)
      end
    end
    if #nextchunk > 0 then
      chunks[#chunks + 1] = makecard(ident, nextchunk)
    end
    return pandoc.Div(chunks)
  end
end

