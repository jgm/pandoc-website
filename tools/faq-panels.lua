local function makepanel(ident, bs)
  local headb = bs[1]
  table.remove(bs, 1)
  table.insert(bs, pandoc.Div({pandoc.Plain{pandoc.Link({pandoc.Span({}, pandoc.Attr("",{"glyphicon","glyphicon-link"}))},"#"..ident)}},
                     pandoc.Attr("",{"link"})))
  local body = pandoc.Div(bs, pandoc.Attr("", {"panel-body"}))
  local head = pandoc.Div({headb}, pandoc.Attr("", {"panel-heading"}))
  return pandoc.Div(
          {pandoc.Div(
            { head
            , pandoc.Div(body, pandoc.Attr("collapse-" .. ident,
                {"panel-collapse","collapse"}))
            },
            pandoc.Attr("", {"panel", "panel-default"}))},
          pandoc.Attr(ident, {"panel-group"}))
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
          chunks[#chunks + 1] = makepanel(ident, nextchunk)
        end
        ident = string.gsub(b.identifier, "%p+", "-")
        b.identifier = ""
        local anchor = pandoc.Link(b.content, "#collapse-" .. ident)
        anchor.attributes["data-toggle"] = "collapse"
        anchor.attributes["data-parent"] = ident
        b.level = 5
        nextchunk = {pandoc.Para{anchor}}
      elseif seen_header then
        table.insert(nextchunk, b)
      end
    end
    if #nextchunk > 0 then
      chunks[#chunks + 1] = makepanel(ident, nextchunk)
    end
    return pandoc.Div(chunks)
  end
end

