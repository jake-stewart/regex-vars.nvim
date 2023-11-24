local VARIABLES = {}

local function termcode(key)
    return vim.api.nvim_replace_termcodes(key, true, true, true)
end

local function input(prompt, onChange)
    local auId = vim.api.nvim_create_autocmd("CmdLineChanged", {
        pattern = "*",
        callback = function()
            onChange(vim.fn.getcmdline())
        end
    })
    local status, result = pcall(function() return vim.fn.input({
        prompt = prompt,
        cancelreturn = false,
    }) end)
    vim.api.nvim_del_autocmd(auId)
    return status and result or nil
end

local matchIds = {}
local function clearMatches()
    while true do
        local matchId = table.remove(matchIds, 1)
        if not matchId then
            return
        end
        vim.fn.matchdelete(matchId)
    end
end

local function escape(buffer)
    return string.gsub(buffer, "[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1")
end

local function formatSearch(buffer)
    for key, value in pairs(VARIABLES) do
        buffer = string.gsub(buffer, key, value)
    end
    return buffer
end

local function handleCase(buffer)
    if vim.o.ignorecase and not
        (vim.o.smartcase and string.find(buffer, "[A-Z]"))
    then
        buffer = "\\c" .. buffer
    end
    return buffer
end

local function search(mode)
    local hlsearch = vim.o.hlsearch
    if vim.o.incsearch then
        vim.o.hlsearch = false
    end
    local line, col = vim.fn.line("."), vim.fn.col(".")

    local result = input(mode, function(buffer)
        if vim.o.incsearch then
            clearMatches()
            if buffer == "" then
                vim.cmd.redraw()
                return
            end
            buffer = formatSearch(buffer)
            local empty = #vim.fn.substitute(
                buffer, "\\C\\v^(\\\\([VvCcMmZ]|\\%C))+", "", "g") == 0
            vim.fn.cursor({line, col})
            if not empty then
                buffer = handleCase(buffer)
                pcall(function()
                    vim.fn.search(buffer, mode == "?" and "b" or "")
                    table.insert(matchIds, vim.fn.matchadd("Search", buffer))
                    if vim.o.incsearch then
                        table.insert(matchIds,
                            vim.fn.matchadd("IncSearch", "\\%#" .. buffer))
                    end
                end)
            end
            vim.cmd.redraw()
        end
    end)
    clearMatches()
    vim.o.hlsearch = hlsearch
    if result then
        local escaped = formatSearch(result):gsub(escape(mode), "\\" .. mode)
        return mode .. escaped .. termcode("<cr>")
    else
        vim.cmd.echo("''")
        return ""
    end
end

return {
    setup = function(variables)
        VARIABLES = variables
        vim.keymap.set(
            {"n", "v", "o"},
            "/",
            function() return search("/") end,
            {expr = true}
        )
        vim.keymap.set(
            {"n", "v", "o"},
            "?",
            function() return search("?") end,
            {expr = true}
        )
    end,
    escape = escape,
}
