-- test_file.lua
require 'dots' -- Require the testing framework

-- require 'my_other_code' -- require your other code to test

-- A Sample Test file.
local basic_test = Dots.Test.new("basic")

-- Test the testing framework
basic_test

:add("Add a test to a test framework.", function(r)
  local falsey = true
  local str = "string"
  local thing = 5
  r:_equal(thing,5,"5 and 5 are not equal")
  r:_truthy(true,"This is not Truthy")
  r:_false(falsey,"This is not false!")
  return r
end)

:add("Add another little thing to these tests.", function(r)
  local silly = "silly"
  local tab = {name="", address="", cars={"ford","honda","mini"}}
  r._match(silly,"silly", "Silly Does not match and why not?")
  r._shape(tab,{name="string",address="string",cars="table", ["___cars"]={"string"}}})
end)