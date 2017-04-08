# Contains various membership function types
# ------------------------------------------

"""	 Membership function type
"""
abstract MF


"""	 Triangular membership function type

	 TriangularMF(l_vertex, center, r_vertex)

	 Properties
	 ----------
	 `l_vertex`, `center` and `r_vertex` are the vertices of the triangle, in order

	 `eval` function returns membership value at a point
	 `mean_at` function returns mean value at line clipped by given firing strength
"""
type TriangularMF<:MF

	l_vertex::Real
	center::Real
	r_vertex::Real

	eval::Function
	mean_at::Function

	function TriangularMF{T<:Real}(l_vertex::T, center::T, r_vertex::T)

		if l_vertex <= center <= r_vertex

			this = new()

			this.l_vertex = l_vertex
			this.center = center
			this.r_vertex = r_vertex

			this.eval = function eval(x)
				maximum([minimum([((x - this.l_vertex) / (this.center - this.l_vertex)), ((this.r_vertex - x) / (this.r_vertex - this.center))]), 0])
			end

			this.mean_at = function mean_at(firing_strength)

				if firing_strength != 1
					p1 = (this.center - this.l_vertex) * firing_strength + this.l_vertex
					p2 = (this.center - this.r_vertex) * firing_strength + this.r_vertex
					(p1 + p2) / 2
				elseif firing_strength == 1
					return this.center
				end

			end

			this

		else

			error("invalid vertices")

		end

	end

end

"""	 Singleton membership function type

	 SingletonMF(value)

	 Properties
	 ----------
	 `value` The value for which the membership is 1

	 `eval` function returns membership value at a point
	 `mean_at` function returns mean value at line clipped by given firing strength
"""
type SingletonMF<:MF

	value::Real

	eval::Function
	mean_at::Function

	function SingletonMF{T<:Real}(value::T)

		this = new()
        this.value = value

		this.eval = function eval(x)
            if x==this.value
                1
            else
                0
            end
		end

		this.mean_at = function mean_at(firing_strength)
            this.value
		end

			this


	end

end



"""
 Gaussian membership function type

	GaussianMF(center, sigma)
t
	 Properties
	 ----------
	 `center` is the center of the distribution
	 `sigma` determines width of the distribution

	 `eval` function returns membership value at a point
	 `mean_at` function returns mean value at line clipped by given firing strength

"""
type GaussianMF<:MF

	center::Real
	sigma::Real

	eval::Function
	mean_at::Function

	function GaussianMF{T<:Real}(center::T, sigma::T)

		this = new()

		this.center = center
		this.sigma = sigma

		this.eval = function eval(x)
			e ^ ( - 0.5 * ((x - this.center) / this.sigma) ^ 2)
		end

		this.mean_at = function mean_at(firing_strength)
			this.center
		end

		this

	end

end

"""
	 Generalised Bell membership function type

	BellMF(a, b, c)

	 Properties
	 ----------
	 `a`, `b` and `c` the usual bell parameters with `c` being the center

	 `eval` function returns membership value at a point
	 `mean_at` function returns mean value at line clipped by given firing strength

"""
type BellMF<:MF

	a::Real
	b::Real
	c::Real

	eval::Function
	mean_at::Function

	function BellMF{T<:Real}(a::T, b::T, c::T)

		this = new()

		this.a = a
		this.b = b
		this.c = c

		this.eval = function eval(x)
			1 / (1 + abs((x - this.c) / this.a) ^ (2 * this.b))
		end

		this.mean_at = function mean_at(firing_strength)
			this.c
		end

		this

	end

end

"""
	 Trapezoidal membership function type

	TrapezoidalMF(l_bottom_vertex, l_top_vertex, r_top_vertex, r_bottom_vertex)

	 Properties
	 ----------
	 `l_bottom_vertex`, `l_top_vertex`, `r_top_vertex` and `r_bottom_vertex` are the vertices of the trapezoid, in order

	 `eval` function returns membership value at a point
	 `mean_at` function returns mean value at line clipped by given firing strength

"""
type TrapezoidalMF<:MF

	l_bottom_vertex::Real
	l_top_vertex::Real
	r_top_vertex::Real
	r_bottom_vertex::Real

	eval::Function
	mean_at::Function

	function TrapezoidalMF{T<:Real}(l_bottom_vertex::T, l_top_vertex::T, r_top_vertex::T, r_bottom_vertex::T)

		if l_bottom_vertex <= l_top_vertex <= r_top_vertex <= r_bottom_vertex

			this = new()

			this.l_bottom_vertex = l_bottom_vertex
			this.l_top_vertex = l_top_vertex
			this.r_top_vertex = r_top_vertex
			this.r_bottom_vertex = r_bottom_vertex

			this.eval = function eval(x)
				maximum([minimum([((x - this.l_bottom_vertex) / (this.l_top_vertex - this.l_bottom_vertex)), 1, ((this.r_bottom_vertex - x) / (this.r_bottom_vertex - this.r_top_vertex))]), 0])
			end

			this.mean_at = function mean_at(firing_strength)
				p1 = (this.l_top_vertex - this.l_bottom_vertex) * firing_strength + this.l_bottom_vertex
				p2 = (this.r_top_vertex - this.r_bottom_vertex) * firing_strength + this.r_bottom_vertex
				(p1 + p2) / 2
			end

			this

		else

			error("invalid vertices")

		end

	end

end

"""
	 Sigmoid membership function type

	SigmoidMF(a, c, limit)

	 Properties
	 ----------
	 `a` controls slope
	 `c` is the crossover point
	 `limit` sets the extreme limit

	 `eval` function returns membership value at a point
	 `mean_at` function returns mean value at line clipped by given firing strength

"""
type SigmoidMF<:MF

	a::Real
	c::Real
	limit::Real

	eval::Function
	mean_at::Function

	function SigmoidMF{T<:Real}(a::T, c::T, limit::T)

		if (a > 0 && limit > c) || (a < 0 && limit < c)

			this = new()

			this.a = a
			this.c = c
			this.limit = limit

			this.eval = function eval(x)
				1 / (1 + exp(-this.a * (x - this.c)))
			end

			this.mean_at = function mean_at(firing_strength)

				if firing_strength == 1
					p_firing_strength = 0.999
				elseif firing_strength == 0
					p_firing_strength = 0.001
				else
					p_firing_strength = firing_strength
				end

				p1 = -log((1 / p_firing_strength) - 1) / this.a + this.c
				p2 = this.limit
				(p1 + p2) / 2

			end

			this

		else

			error("invalid parameters")

		end

	end

end
