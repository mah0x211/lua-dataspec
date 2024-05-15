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
local next = next
local pairs = pairs
local type = type
local rawset = rawset
local is_int = require('lauxhlib.is').int
local fatalf = require('error.fatalf')
local verify_pascal_ident = require('dataspec.identifier').verify_pascal_ident

--- @class dataspec.enum
--- @field public tag string
--- @field protected values table<string, number>
local Enum = {}

--- __newindex raise an error
function Enum:__newindex()
    fatalf(2, 'attempt to change constant enum %q', self.tag)
end

--- __index returns the value of the identifier
--- @param k string
--- @return integer
function Enum:__index(k)
    local v = self.values[k]
    if not v then
        fatalf(2, 'identifier %q not defined in enum %q', k, self.tag)
    end
    return v
end

--- init
--- @param tag string
--- @param tbl table
--- @return dataspec.enum
function Enum:init(tag, tbl)
    if type(tbl) ~= 'table' or not next(tbl) then
        fatalf(2, 'argument#2 must be non-empty table')
    end

    local values = {}
    for id, val in pairs(tbl) do
        -- array
        if is_int(id) then
            id, val = val, id
        end

        verify_pascal_ident(id, 3)
        if values[id] then
            fatalf(2, 'member identifier %q already defined', id)
        elseif not is_int(val) then
            fatalf(2, 'member identifier %q value %q must be integer', id, val)
        end
        values[id] = val
    end

    rawset(self, 'tag', tag)
    rawset(self, 'values', values)
    return self
end

--- check whether the value is valid enumerated value
--- @param v string
--- @return boolean? ok
function Enum:check(v)
    local t = type(v)
    if t == 'string' then
        return self.values[v] ~= nil
    end
    fatalf(2, 'argument#1 must be string')
end

Enum = require('metamodule').new(Enum)
return require('dataspec.identifier').new(function(name, ...)
    return Enum(name, ...)
end)
