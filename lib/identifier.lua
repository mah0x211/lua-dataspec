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
local is_callable = require('lauxhlib.is').callable
local is_pint = require('lauxhlib.is').pint
local fatalf = require('error.fatalf')

local PAT_IDENT = '^[_a-zA-Z][_a-zA-Z0-9]*$'

--- verify_ident validate identifier tag string if the identifier is invalid,
--- then this function will raise an error.
--- @param tag string
--- @param lv integer?
local function verify_ident(tag, lv)
    if lv == nil then
        lv = 3
    elseif not is_pint(lv) then
        fatalf(2, 'lv must be positive integer')
    else
        lv = lv + 1
    end

    if type(tag) ~= 'string' or not find(tag, PAT_IDENT) then
        fatalf(lv, 'identifier %q is not type of string in the form %q',
               tostring(tag), PAT_IDENT)
    end
end

--- @class dataspec.identifier
--- @field callback fun(name:string, ...):any
local Identifier = {}

--- init
--- @param callback function(name:string, ...):any
--- @return dataspec.identifier
function Identifier:init(callback)
    if not is_callable(callback) then
        fatalf(2, 'callback must be callable')
    end
    self.callback = callback
    return self
end

--- __call
--- @param tag string
--- @return fun(...):any
function Identifier:__call(tag)
    verify_ident(tag)
    return function(...)
        return self.callback(tag, ...)
    end
end

return {
    new = require('metamodule').new(Identifier),
    verify_ident = verify_ident,
}

