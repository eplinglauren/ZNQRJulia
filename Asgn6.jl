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

# type definitions for Values
abstract type Value end
# environment type
const Env = Dict{Symbol,Value}
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
	env::Env
end

# top environment
topEnv = Dict((Symbol(+)=>PrimV(Symbol(+))),
(Symbol(-)=>PrimV(Symbol(-))),
(Symbol(*)=>PrimV(Symbol(*))),
(Symbol(/)=>PrimV(Symbol(/))),
(Symbol(<=)=>PrimV(Symbol(<=))),
(Symbol("equal")=>PrimV(Symbol("equal"))),
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
		return NumV(a.n + b.n)
	else
		error("ZNQR: must add numbers only")
	end
end

# prim_sub takes two values and subtracts b from a
# it throws an error if user is not subtracting numbers
function prim_sub(a::NumV, b::NumV)
	if typeof(a)!=NumV && typeof(b)!=NumV
		error("ZNQR: must subtract numbers only")
	else
		return NumV(a.n - b.n)
	end
end

# prim_mult takes two values and multiplies them
# it throws an error if the values are not numbers
function prim_mult(a::NumV, b::NumV)
	if typeof(a)!=NumV && typeof(b)!=NumV
		error("ZNQR: must multiply numbers only")
	else
		return NumV(a.n * b.n)
	end
end

# prim_div takes two values and divides them
# it throws an error if the values are not numbers,
# or if the user is trying to divide by zero
function prim_div(a::NumV, b::NumV)
	if typeof(a)==NumV && typeof(b)==NumV
		if b.n != 0
			return NumV(a.n / b.n)
		else
			error("ZNQR: divide numbers only, and not by zero")
		end
	end
end

# prim_lte accepts two values and returns true
# if a <= b. it signals an error if either a or b
# are not a number.
function prim_lte(a::NumV,b::NumV)
	if typeof(a)==NumV && typeof(b)==NumV
		if a.n <= b.n
			return BoolV(true)
		else
			return BoolV(false)
		end
	else
		error("ZNQR: use numbers only for <=")
	end
end

# prim_equal accepts two values and returns true
# if neither value is a closure or a primop and
# the two values are equal. no error signals.
function prim_equal(a::Value,b::Value)
	if (typeof(a) != PrimV || CloV) && (typeof(b)!= PrimV || CloV)
		if typeof(a)==NumV && typeof(b)==NumV
			if a.n == b.n
				return BoolV(true)
			else
				return BoolV(false)
			end
		elseif typeof(a)==StringV && typeof(b)==StringV
			if a.str == b.str
				return BoolV(true)
			else
				return BoolV(false)
			end
		elseif typeof(a)==BoolV && typeof(b)==BoolV
			if a.b == b.b
				return BoolV(true)
			else
				return BoolV(false)
			end
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
	@test prim_add(NumV(2), NumV(1)) == NumV(3)
	@test prim_add(NumV(10), NumV(20)) == NumV(30)
	@test_throws MethodError prim_add(BoolV(true), NumV(2))
end

@testset "prim_sub" begin
	@test prim_sub(NumV(10), NumV(2)) == NumV(8)
	@test prim_sub(NumV(1), NumV(2)) == NumV(-1)
	@test_throws MethodError prim_sub(BoolV(false),NumV(10))
end

@testset "prim_mult" begin
	@test prim_mult(NumV(10), NumV(2)) == NumV(20)
	@test_throws MethodError prim_mult(BoolV(true), NumV(2))
end

@testset "prim_div" begin
	@test prim_div(NumV(10), NumV(2)) == NumV(5.0)
	@test_throws ErrorException prim_div(NumV(10), NumV(0))
	@test_throws MethodError prim_div(BoolV(true), NumV(3))
end

@testset "prim_lte" begin
	@test prim_lte(NumV(10), NumV(5)) == BoolV(false)
	@test prim_lte(NumV(2), NumV(5)) == BoolV(true)
	@test_throws MethodError prim_lte(NumV(2), BoolV(true))
end

@testset "prim_equal" begin
	@test prim_equal(NumV(2), NumV(2)) == BoolV(true)
	@test prim_equal(NumV(2), NumV(6)) == BoolV(false)
	@test prim_equal(BoolV(true), BoolV(false)) == BoolV(false)
	@test prim_equal(BoolV(false), BoolV(false)) == BoolV(true)
	@test prim_equal(StringV("hey"), StringV("hey")) == BoolV(true)
	@test prim_equal(StringV("hello"), StringV("hi")) == BoolV(false)
end