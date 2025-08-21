1. Functional dependencies.
	1. What functional dependencies are implied if we know that a set of attributes _X_ is a candidate key for a relation _R_?
		1. X functionally determines all of the other attributes. (because x is a condidate key that means it is unique)
	2. What functional dependencies can we infer _do not hold_ by inspection of the following relation?
		1. valid functional dependencies
			1. A -> B
			2. B -> A
		2. invalid functional dependencies
			1. A -> C (a -> x but a->y)
			2. B -> C (1 -> x but 1-> y)
			3. AB -> C
			4. C -> A
			5. C -> B
			6. B -> A 
			7. B -> C
	3. Suppose that we have a relation schema _R(A,B,C)_ representing a relationship between two entity sets _E_ and _F_ with keys _A_ and _B_ respectively, and suppose that _R_ has (at least) the functional dependencies _A → B_ and _B → A_. Explain what this tells us about the relationship between _E_ and _F_.
		1. A -> B: every A value in R has exactly one corresponding B value.
		2. B -> A: every B value has exactly one corresponding A value
		3. means teh relationship in between is 1 : 1
