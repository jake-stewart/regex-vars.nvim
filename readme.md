regex-vars.nvim
===============
allows defining variables which are expanded during search. for example, you
could make a `:email:` variable which you type and automatically expands to an
email regex.

it also changes the functionality of typing `/` (or `?` if backwards). default
functionality is to use previous search if empty or end the search. the new behaviour
is to automatically escape these characters. if you wish to use the previous
search, you can still leave the search empty or use `<c-p>`.


### setup
```lua
local rv = require("regex-vars")

rv.setup({
    [rv.escape(":foo:")] = "bar",
})
```

### usage
with the example config, `[foo]` is mapped to `bar`. you can use `/` or `?` to
search and `[foo]` in your search will be replaced with `bar`.
