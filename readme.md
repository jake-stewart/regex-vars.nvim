regex-vars.nvim
===============

### setup
```lua
local escape = require("search").escape

require("search").setup({
    [escape("[foo]")] = "bar"
})
```

### usage
with the example config, `[foo]` is mapped to `bar`. you can use `/` or `?` to
search and `[foo]` in your search will be replaced with `bar`.
