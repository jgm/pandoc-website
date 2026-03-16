function Link(el)
    if string.find(el.target, "%.md$") then
        el.target = el.target:gsub("%.md$", ".html")
        return el
    end
end
