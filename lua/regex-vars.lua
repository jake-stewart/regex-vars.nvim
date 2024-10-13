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
        buffer = string.gsub(buffer, key, "\\v" .. value .. "\\V")
    end
    return string.gsub(buffer, "\\V\\v", "")
end

local function addFlags(buffer)
    local ignorecase = vim.o.ignorecase
    local backslash = false
    for i = 1, #buffer do
        local char = string.sub(buffer, i, i)
        if backslash then
            if char == "C" then
                ignorecase = false
            elseif char == "c" then
                -- \c anywhere in regex makes the whole ignorecase
                ignorecase = true
                break
            end
            backslash = false
        elseif char == "\\" then
            backslash = true
        end
    end
    local magic = (vim.o.magic and "\\m" or "\\M")
    local case = (ignorecase and "\\c" or "\\C")
    local smartCase = ignorecase and vim.o.smartcase and string.find(buffer, "[A-Z]")
    return (smartCase and "\\C" or case) .. magic .. buffer
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
                buffer = addFlags(buffer)
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
    if not result then
        return mode .. termcode("<c-c>")
    end
    local escaped = formatSearch(result):gsub(escape(mode), "\\" .. mode)
    return mode .. escaped .. termcode("<cr>")
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
