-- put nowrap tags around options
function Code(el)
  if el.text:match("--") then
      return {pandoc.Span({el}, pandoc.Attr("", {"nowrap"}))}
  end
end
