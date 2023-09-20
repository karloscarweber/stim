-- lox/test.lua
require 'dots'

-- Setup Testing Context
context = Dots:new()

test_files = Dots.tests_in('lox/test')
tasky = Dots.Task:new("Basic Test", test_files)
context:add(tasky)

context:execute()

-- parse each one in order, logging syntax errors.

-- Add green dots for successful tests.

-- print the logged errors at the end.


-- Run Tests
-- tests = {}
-- Test = {}
-- function Test:new(summary, funk)
--   local t = {
--     summary = summary,
--     funk = funk,
--   }
--   return t
-- end
