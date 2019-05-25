# type definitions for ExprC
abstract type ExprC end
struct NumC <: ExprC
	n::Real
end
struct StringC <: ExprC
	str::String
end
struct IdC <: ExprC
	s::Symbol
end
struct AppC <: ExprC
	fn::ExprC
	arg::Array{ExprC,1}
end
struct LamC <: ExprC
	arg::Array{Symbol,1}
	body::ExprC
end

# environment type
# abstract type Env <: Dict{Symbol,Value} end

# type definitions for Values
abstract type Value end
struct NumV <: Value
	n::Real
end
struct StringV <: Value
	str::String
end
struct BoolV <: Value
	b::Bool
end
struct PrimV <: Value
	op::Symbol
end
struct CloV <: Value
	arg::Array{Symbol,1}
	body::ExprC
	# env::Env
end

# top environment
topEnv = Dict((Symbol(+)=>PrimV(Symbol(+))),
(Symbol(-)=>PrimV(Symbol(-))),
(Symbol(*)=>PrimV(Symbol(*))),
(Symbol(/)=>PrimV(Symbol(/))),
(Symbol(<=)=>PrimV(Symbol(<=))),
(Symbol("equal?")=>PrimV(Symbol("equal?"))),
(Symbol("if")=>PrimV(Symbol("if"))),
(Symbol(true)=>BoolV(true)),
(Symbol(false)=>BoolV(false)))

# serialize accepts a value and returns
# the serialized (string) version of the value
function serialize(v::Value)
	if typeof(v)==NumV
		return string(getfield(v, :n))
	elseif typeof(v)==StringV
		return string(getfield(v, :str))
	elseif typeof(v)==BoolV
		return string(getfield(v, :b))
	elseif typeof(v)==PrimV
		return "#<primop>"
	else
		return "#<procedure>"
	end
end

# prim_add takes two values and adds them
# it throws an error if user is not adding numbers
function prim_add(a::NumV, b::NumV)
	if typeof(a)==NumV && typeof(b)==NumV
		return getfield(a, :n) + getfield(b, :n)
	else
		warn("ZNQR: must add numbers only")
	end
end

# prim_sub takes two values and subtracts b from a
# it throws an error if user is not subtracting numbers
function prim_sub(a::NumV, b::NumV)
	if typeof(a)==NumV && typeof(b)==NumV
		return getfield(a, :n) - getfield(b, :n)
	else
		warn("ZNQR: must subtract numbers only")
	end
end

# prim_mult takes two values and multiplies them
# it throws an error if the values are not numbers
function prim_mult(a::NumV, b::NumV)
	if typeof(a)==NumV && typeof(b)==NumV
		return getfield(a, :n) * getfield(b, :n)
	else
		warn("ZNQR: must multiply numbers only")
	end
end

# prim_div takes two values and divides them
# it throws an error if the values are not numbers,
# or if the user is trying to divide by zero
function prim_div(a::NumV, b::NumV)
	if typeof(a)==NumV && typeof(b)==NumV
		if getfield(b, :n) != 0
			return getfield(a, :n) / getfield(b, :n)
		else
			warn("ZNQR: divide numbers only, and not by zero")
		end
	end
end

# Test Cases
using Test
@testset "serialize" begin
	@test serialize(NumV(2)) == "2"
	@test serialize(StringV("hi")) == "hi"
	@test serialize(BoolV(true)) == "true"
	@test serialize(PrimV(Symbol(+))) == "#<primop>"
end

@testset "prim_add" begin
	@test prim_add(NumV(2), NumV(1)) == 3
	@test prim_add(NumV(10), NumV(20)) == 30
	@test_throws ErrorException prim_add(BoolV(true), NumV(2))
end

@testset "prim_sub" begin
	@test prim_sub(NumV(10), NumV(2)) == 8
	@test prim_sub(NumV(1), NumV(2)) == -1
	@test_throws MethodError prim_sub(BoolV(false),NumV(10))
end

@testset "prim_mult" begin
	@test prim_mult(NumV(10), NumV(2)) == 20
	@test_throws MethodError prim_mult(BoolV(true), NumV(2))
end

@testset "prim_div" begin
	@test prim_div(NumV(10), NumV(2)) == 5
	@test_throws UndefVarError prim_div(NumV(10), NumV(0))
	@test_throws MethodError prim_div(BoolV(true), NumV(3))
end