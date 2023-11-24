regex-vars.nvim
===============

### setup
```lua
local escape = require("regex-vars").escape

require("regex-vars").setup({
    [escape("/")] = "\\/",
    [escape("[foo]")] = "bar"
})
```

### usage
with the example config, `[foo]` is mapped to `bar`. you can use `/` or `?` to
search and `[foo]` in your search will be replaced with `bar`.

i also included `/` to expand to `\\/` so that you no longer have to escape `/` in your search. to access last search just use `<c-p>`.
