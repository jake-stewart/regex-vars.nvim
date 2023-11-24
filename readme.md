regex-vars.nvim
===============

![regex-vars-demo](https://github.com/jake-stewart/regex-vars.nvim/assets/83528263/dd961a75-9b25-43e0-ad14-2a110f1fa14a)

allows defining variables which are expanded during search. for example, you
could make a `:email:` variable which you type and automatically expands to an
email regex.

it supports `incsearch` and respects your `'magic'`, `'ignorecase'`, `'smartcase'`, settings.

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
