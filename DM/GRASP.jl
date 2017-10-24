

function GRASP(objective, constraints, alpha)

    m,n = size(constraints)

    C = [1:n;] # List of candidates
    x0 = zeros(Int8,n)
    uFactors = fill((1,1.0),n)

    while size(C,1) != 0

        uFactors = updateUtilities(objective, constraints, C)

        #println("C : ", C)
        #println(size(C,1))

        limit = uFactors[size(uFactors,1)][2] + alpha*(uFactors[1][2] - uFactors[size(uFactors,1)][2])
        #println("limite : ", limit)
        #println("uFactors : ", uFactors)

        #Initialzing some variables for RCL construction
        i = 1
        RCL = []

        #Generating RCL
        for i=1:size(uFactors,1) 
            if uFactors[i][2] >= limit
                push!(RCL, uFactors[i][1])
            end
        end

        #println("RCL : ", RCL)
        selected = RCL[floor(rand(1:size(RCL,1)))]
        x0[selected] = 1
        #println("selected : ", selected)

        #Updating C by deleting every variable that's part of a saturated constraint
        deleteat!(C,findfirst(selected))

        for constr = 1:m
            if constraints[constr, selected] == 1
                #println("Constraint ",constr, " is now saturated")
                for dvar = 1:n
                    if constraints[constr, dvar] == 1 && findfirst(C,dvar) != 0
                        deleteat!(C,findfirst(C,dvar))
                    end
                end
            end
        end

    end

    return x0

end

#Returns a new uFactors array, only containing elements from our C set
function updateUtilities(objective, constraints, C)

    m,n = size(constraints)
    uFactors = fill((1,1.0), size(C,1))

    for j=1:size(C,1)
        #on compte le nombre de fois où la variable est dans une contrainte
        c = 1 # on initialise à 1 au cas où une variable ne serait présente dans aucune contrainte (peu probable)
        for i=1:m
            if constraints[i,C[j]] == 1 #Si la variable fait partie de la conditiont testée, count++
                c += 1
            end
        end
        utility = objective[j]/c
        uFactors[j] = (C[j], utility)
    end

    return uFactors

end