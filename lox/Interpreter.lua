-- lox/Interpreter.lua

Interpreter = {}

-- create a new parser by calling Interpreter:new()
function Interpreter:new()
  local t = {
  }
  setmetatable(t,self)
  self.__index = self
  return t
end

function Interpreter:inty(expression)
  local value = self:evaluate(expressions)
  print(tostring(value))
end

function Interpreter:interpret(expression)
  if (pcall(self:inty(expression))) == true then
    print("This broke")
  end
end

-- visits a literal expression simply returning it's value
function Interpreter:visitLiteralExpr(expr)
  return expr.value
end

function Interpreter:visitGroupingExpr(expr)
  return evaluate(expr.expression)
end

function Interpreter:evaluate(expr)
  return expr.accept(self)
end

local ut = {MINUS, BANG} -- unary Table
function Interpreter:visitUnaryExpr(expr)
  local right = evaluate(expr.right)

  if table.has_value(ut, MINUS) then
    self:checkNumberOperand(expr.operator, right)
    return not(self:isTruthy(right))
  elseif expr.operator.type == BANG then
    return -tonumber(right) -- translate this
  end

  -- Unreachable
  return nil
end

function Interpreter:checkNumberOperand(operator, operand)
  if type(operand) == number then return end
  error("Operand must be a number. " .. operator.toString())
end

function Interpreter:checkNumberOperands(operator, left, right)
  if (type(left) == "number") && (type(right) == "number") then return end
  error("Operands must be numbers: " .. operator.toString())
end

function Interpreter:isTruthy(object)
  if object == nil then return false end
  if type(object) == "boolean" then return object end;
  return true
end

function Interpreter:isEqual(a,b)
  if (a==nil and b==nil) then return true end
  if (a==nil) then return false end
  return (a==b)
end

function Interpreter:stringify(object)
  if object == nil return "nil" end

  if type(object) == "number" then
    local text = object.toString()
    if (text.endsWith(".0")) then
      text = text.substring(0, #text - 2)
    end
    return text
  end

  return object.toString()
end

local bt = {MINUS, SLASH, START}
function Interpreter:visitBinaryExpr(expr)
  local left = self:evaluate(expr.left)
  local right = self:evaluate(expr.right)
  local typ = expr.operator.type

  if typ == GREATER then
    self:checkNumberOperands(expr.operator, left, right)
    return tonumber(left) > tonumber(right)
  if typ == GREATER_EQUAL then
    self:checkNumberOperands(expr.operator, left, right)
    return tonumber(left) >= tonumber(right)
  if typ == LESS then
    self:checkNumberOperands(expr.operator, left, right)
    return tonumber(left) < tonumber(right)
  if typ == LESS_EQUAL then
    self:checkNumberOperands(expr.operator, left, right)
    return tonumber(left) <= tonumber(right)
  elseif typ == MINUS then
    self:checkNumberOperands(expr.operator, left, right)
    return tonumber(left) - tonumber(right)
  elseif typ == PLUS then
    if (type(left) == "number") and (type(right) == "number") then
      return tonumber(left) + tonumber(right)
    end
    if (type(left) == "string") and (type(right) == "string") then
      return tostring(left) + tostring(right)
    end
    error("Operands must be two numbers or two strings." .. expr.operator.toString())
  elseif typ == SLASH then
    self:checkNumberOperands(expr.operator, left, right)
    return tonumber(left) / tonumber(right)
  elseif typ == STAR then
    self:checkNumberOperands(expr.operator, left, right)
    return tonumber(left) * tonumber(right)
  elseif typ == BANG_EQUAL then
    return not(Interpreter:isEqual(left,right))
  elseif typ == EQUAL_EQUAL then
    return Interpreter:isEqual(left,right)
  end

  -- Unreachable
  return nil
end
