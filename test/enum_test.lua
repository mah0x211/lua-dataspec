require('luacov')
local testcase = require('testcase')
local assert = require('assert')
local enum = require('dataspec.enum')

function testcase.create_enum()
    -- test that create enumerated
    local myenum = enum 'myenum' {
        Name1 = 1,
        'Name2',
        'Name3',
    }
    assert.re_match(myenum, '^dataspec.enum: ')

    -- test that access enumerated value
    assert.equal(myenum.Name1, 1)
    assert.equal(myenum.Name2, 1)
    assert.equal(myenum.Name3, 2)

    -- test that throws error if access invalid enumerated value
    local err = assert.throws(function()
        local _ = myenum.name4
    end)
    assert.match(err, 'identifier "name4" not defined in enum "myenum"')

    -- test that throws error if attempt to change enumerator
    err = assert.throws(function()
        myenum.Name1 = 2
    end)
    assert.match(err, 'attempt to add a new property "Name1" to "myenum"')

    -- test that throw error if identifier is invalid
    err = assert.throws(function()
        enum '123' {}
    end)
    assert.match(err, 'identifier "123" is not type of string in the form')

    -- test that throw error if empty table
    err = assert.throws(function()
        enum 'myenum' {}
    end)
    assert.match(err, 'argument#2 must be non-empty table')

    -- test that throw error if member identifier is invalid
    err = assert.throws(function()
        enum 'myenum' {
            name1 = 1,
        }
    end)
    assert.match(err, 'identifier "name1" is not type of string in the form')

    -- test that throw error if identifier already defined
    err = assert.throws(function()
        enum 'myenum' {
            Name1 = 1,
            'Name1',
        }
    end)
    assert.match(err, 'identifier "Name1" already defined')

    -- test that throw error if identifier value is not integer
    err = assert.throws(function()
        enum 'myenum' {
            Name1 = 1,
            Name2 = 1 / 0,
        }
    end)
    assert.match(err, 'identifier "Name2" value "inf" must be integer')
end

function testcase.check()
    local myenum = enum 'myenum' {
        Name1 = 1,
        'Name2',
        'Name3',
    }

    -- test that return true if valid enumerated value
    assert.is_true(myenum:check('Name1'))
    assert.is_true(myenum:check('Name2'))
    assert.is_true(myenum:check('Name3'))

    -- test that return false if invalid enumerated value
    assert.is_false(myenum:check('Name4'))

    -- test that throw error if argument is not string
    local err = assert.throws(function()
        myenum:check(1)
    end)
    assert.match(err, 'argument#1 must be string')
end

