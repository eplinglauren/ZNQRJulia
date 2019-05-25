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

# environment type
# abstract type Env <: Dict{Symbol,Value} end
topEnv = Dict((Symbol(+)=>PrimV(Symbol(+))),
(Symbol(-)=>PrimV(Symbol(-))),
(Symbol(*)=>PrimV(Symbol(*))),
(Symbol(/)=>PrimV(Symbol(/))),
(Symbol(<=)=>PrimV(Symbol(<=))),
(Symbol("equal?")=>PrimV(Symbol("equal?"))),
(Symbol("if")=>PrimV(Symbol("if"))),
(Symbol(true)=>BoolV(true)),
(Symbol(false)=>BoolV(false)))