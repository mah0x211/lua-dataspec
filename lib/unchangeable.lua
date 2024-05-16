--
-- Copyright (C) 2024 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
local fatalf = require('error.fatalf')

--- @class dataspec.unchangeable
--- @field protected tag string
local Unchangeable = {}

--- __newindex throws error when attempting to add a new property directly
--- @param k string
function Unchangeable:__newindex(k)
    fatalf(2, 'attempt to add a new property %q to %q directly', k, self.tag)
end

--- __index throws error when attempting to access an undefined property
--- @param k string
--- @throw error
function Unchangeable:__index(k)
    fatalf(2, 'attempt to access undefined property %q of %q', k, self.tag)
end

-- luacheck: ignore
Unchangeable = require('metamodule').new(Unchangeable)

