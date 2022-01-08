-- Linkify issue references like #123 in changelog.md to GitHub.
local github_tracker = true

function Str(el)
    if el.text == '(2011-02-13)' then
        -- from that release pandoc used a different issue
        -- tracker so we stop linking issues to GitHub
        github_tracker = false
        return
    end

    if github_tracker then
        start, _end = el.text:find('#%d+')
        if start ~= nil then
            new_text = {}
            table.insert(new_text, pandoc.Str(string.sub(el.text, 0, start - 1)))
            issue_number = string.sub(el.text, start + 1, _end)
            issue_url = 'https://github.com/jgm/pandoc/issues/' .. issue_number
            link_label = pandoc.Str('#' .. issue_number)
            table.insert(new_text, pandoc.Link(link_label, issue_url, '', {}))
            table.insert(new_text, pandoc.Str(string.sub(el.text, _end + 1)))
            return new_text
        end
    end
end
