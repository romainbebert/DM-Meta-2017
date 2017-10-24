#Gives an x0 solution to the SPP instance given that will need to be improved with local search

function pacman(objective, constraints)

    m,n = size(constraints)

    uFactors = fill((1,1.0),n)
    solution = zeros(Int8,n)
    usedVariables = []

    #Let's compute every variable's utility factor
    for j=1:n
        #on compte le nombre de fois où la variable est dans une contrainte
        c = 1 # on initialise à 1 au cas où une variable ne serait présente dans aucune contrainte (peu probable)
        for i=1:m
            if constraints[i,j] == 1 #Si la variable fait partie de la conditiont testée, count++
                c += 1
            end
        end
        utility = objective[j]/c
        uFactors[j] = (j, utility)
    end

    sort!(uFactors, rev=true, by = x -> x[2]) #Sort by utility

    #On itère à travers l'ensemble du vecteur de facteurs d'utilité
    for i=1:n

        if findfirst(usedVariables, uFactors[1][1]) == 0
        	#Puis pour chaque condition, on vérifie si la variable sélectionnée résoud cette dernière. On vérifie aussi si la variable a déjà été utilisée
            for constr=1:m
                if constraints[constr, uFactors[1][1]] == 1
                	for dvar=1:n
                		#Si une variable est contenu dans la condition qu'on vient de saturer, on note la variable comme utilisée
                		if constraints[constr,dvar] == 1
                    		push!(usedVariables, dvar)
                    	end
                    end
                    solution[uFactors[1][1]] = 1
                end
            end
        end

        shift!(uFactors)

    end

    return solution

end
