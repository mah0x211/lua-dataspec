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
local type = type
local tostring = tostring
local find = string.find
local rawset = rawset
local is_callable = require('lauxhlib.is').callable
local is_pint = require('lauxhlib.is').pint
local fatalf = require('error.fatalf')

local VERIFIERS = {
    FIELD_IDENT = '^[_a-zA-Z][_a-zA-Z0-9]*$',
    PASCAL_IDENT = '^[A-Z][_a-zA-Z0-9]*$',
}

--- verify identifier tag string is match with specified pattern.
--- if not match, then raise an error.
--- @param pattern string
--- @param tag string
--- @param lv integer?
local function verify_ident(pattern, tag, lv)
    if lv == nil then
        lv = 3
    elseif not is_pint(lv) then
        fatalf(2, 'lv must be positive integer')
    else
        lv = lv + 1
    end

    if type(tag) ~= 'string' or not find(tag, pattern) then
        fatalf(lv, 'identifier %q is not type of string in the form %q',
               tostring(tag), pattern)
    end
end

--- verify identifier tag string is match with '^[_a-zA-Z][_a-zA-Z0-9]*$' pattern.
--- if not match, then raise an error.
--- @param tag string
--- @param lv integer?
local function verify_field_ident(tag, lv)
    return verify_ident(VERIFIERS.FIELD_IDENT, tag, lv)
end

--- verify identifier tag string is match with '^[A-Z][_a-zA-Z0-9]*$' pattern.
--- if not match, then raise an error.
--- @param tag string
--- @param lv integer?
local function verify_pascal_ident(tag, lv)
    return verify_ident(VERIFIERS.PASCAL_IDENT, tag, lv)
end

--- @class dataspec.identifier : dataspec.unchangeable
--- @field private pattern string
--- @field private callback fun(name:string, ...):any
local Identifier = {}

--- init
--- @param callback function(name:string, ...):any
--- @param pattern string? 'FIELD_IDENT' or 'PASCAL_IDENT' or custom pattern string (default: 'FIELD_IDENT')
--- @return dataspec.identifier
function Identifier:init(callback, pattern)
    if not is_callable(callback) then
        fatalf(2, 'callback must be callable')
    end

    if pattern == nil then
        rawset(self, 'pattern', VERIFIERS.FIELD_IDENT)
    elseif type(pattern) ~= 'string' or find(pattern, '^%s*$') then
        fatalf(2, 'pattern must be non-empty string or nil')
    else
        local verifier = VERIFIERS[pattern]
        if not verifier then
            verifier = pattern
        end
        rawset(self, 'pattern', verifier)
    end
    rawset(self, 'callback', callback)
    return self
end

--- __call
--- @param tag string
--- @return fun(...):any
function Identifier:__call(tag)
    verify_ident(self.pattern, tag)
    return function(...)
        return self.callback(tag, ...)
    end
end

return {
    new = require('metamodule').new(Identifier, 'dataspec.unchangeable'),
    verify_ident = verify_ident,
    verify_field_ident = verify_field_ident,
    verify_pascal_ident = verify_pascal_ident,
}

