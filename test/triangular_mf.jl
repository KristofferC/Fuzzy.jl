l_vertex = 2.0
center = 5.0
r_vertex = 7.0

mf = TriangularMF(l_vertex, center, r_vertex)

# Evaluation tests
@assert Fuzzy.evaluate(mf, center) == 1
@assert Fuzzy.evaluate(mf, l_vertex) == Fuzzy.evaluate(mf, r_vertex) == 0.0
@assert Fuzzy.evaluate(mf, (l_vertex + center) / 2.0) == Fuzzy.evaluate(mf, (r_vertex + center) / 2.0) == 0.5

# Mean finding tests
@assert Fuzzy.mean_at(mf, 1.0) == center
@assert Fuzzy.mean_at(mf, 0.0) == (l_vertex + r_vertex) / 2.0
