-- lox/Parser.lua
--
-- The parser for our Lua based Programming language

require 'lox/token_type'
require 'lox/Lox'
require 'lox/helpers'

-- Parser
-- Namespace for the parser class
Parser = {}

-- Write a Parser error Class
ParserError = function()
	local t = {}
	t.name = "Parser Error"
	t.purpose = "report errors?"
	return t
end

-- Generates a new parser object
--
-- 	@tokens - An array of tokens
--  @current - an int representing the current token, starts at 1.
--
-- 	init(@tokens) - implicit contstructor, accepts a tokens parameter.
function Parser:new(tokens)
	local t = {
		current = 1,
		tokens = tokens,
		["ParserError"] = ParserError,
	}
	setmetatable(t,self)
	self.__index = self
	return t
end

-- parse
-- Accepts nothing, but spits out an array of statements.
--
function Parser:parse()
	-- pcall, returns true, and nothing if there is no error
	-- otherwise it returns false, and an error.
	-- local status, err = pcall(foo)
	-- if status then
	-- 	return
	-- else
	-- 	return nil
	-- end
	local statements = {}
	while not self:isAtEnd() do
		table.insert(statements, self:statement())
	end
	return statements
end

-- local someTokens = getTokens()
-- local parser = Parser:new(tokens)

-- functions that parse the syntax tree and return Raw Lua code

function Parser:expression()
	return self:equality()
end

function Parser:statement()
	if self:match(PRINT) then return self:printStatement() end
	return self:expressionStatement()
end

function Parser:printStatement()
	local value = self:expression()
	self:consume(SEMICOLON, "expect ';' after value.")
	return Stmt.Print(value)
end

function Parser:expressionStatement()
	local expr = self:expression()
	self:consume(SEMICOLON, "expect ';' after expression.")
	return Stmt.Expression(value)
end

function Parser:equality()
	local expr = self:comparison()

	while (self:match(BANG_EQUAL, EQUAL_EQUAL)) do
		local operator = self:previous()
		local right = self:comparison()
		expr = Expr.Binary(expr, operator, right)
	end

	return expr
end

function Parser:comparison()
	local expr = self:term()

	while(self:match(GREATER, GREATER_EQUAL, LESS, LESS_EQUAL)) do
		local operator = self:previous()
		local right = self:term()
		expr = Expr.Binary(expr, operator, right)
	end

	return expr
end

function Parser:term()
	local expr = self:factor()

	while(self:match(MINUS, PLUS)) do
		local operator = self:previous()
		local right = self:factor()
		expr = Expr.Binary(expr, operator, right)
	end

	return expr
end

function Parser:factor()
	local expr = self:unary()

	while(self:match(SLASH, STAR)) do
		local operator = self:previous()
		local right = self:unary()
		expr = Expr.Binary(expr, operator, right)
	end

	return expr
end

function Parser:unary()
	if(self:match(BANG, MINUS)) then
		local operator = self:previous()
		local right = self:unary()
		return Expr.Unary(operator, right)
	end
	return self:primary()
end

function Parser:primary()
	if (self:match(FALSE)) then return Expr.Literal(false) end
	if (self:match(TRUE)) then return Expr.Literal(true) end
	if (self:match(NIL)) then return Expr.Literal(nil) end

	if(self:match(NUMBER, STRING)) then
		return Expr.Literal(self:previous().literal)
	end

	if(self:match(LEFT_PAREN)) then
		local expr = self:expression()
		self:consume(RIGHT_PAREN, "Expect ')' after expression.")
		return Expr.Grouping(expr)
	end

	error("Expect expression. : " .. self:peek().lexeme)
end

function Parser:match(...)
	local types = {...}
	for _,type in ipairs(types) do
		if self:check(type) then
			self:advance()
			return true
		end
	end

	return false
end

function Parser:consume(type, message)
	if self:check(type) then return self:advance() end

	self:error(self:peek(), message)
end

function Parser:check(type)
	if self:isAtEnd() then return false end
	return (self:peek().type == type)
end

function Parser:advance()
	if not (self:isAtEnd()) then self.current = self.current + 1 end
	return self:previous();
end

function Parser:isAtEnd()
	return self:peek().type == EOF
end

function Parser:peek()
	return self.tokens[self.current]
end

function Parser:previous()
	return self.tokens[self.current-1]
end

function Parser:error(token, message)
	Lox.token_error(token, message)
	return ParserError()
end

-- synchronize
local switchcase = {CLASS, FUN, VAR, FOR, IF, WHILE, PRINT, RETURN}
function Parser:synchronize(token, message)
	self:advance()
	while not(self:isAtEnd()) do
		if (self:previous().type == SEMICOLON) then return end
		if table.has_value(switchcase, self:peek().type) then
			return
		end
		self:advance()
	end
end
