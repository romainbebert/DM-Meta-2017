
#This localSearch uses 1-1 exchanges for performance's sake
#but 1-0 exchanges could be an interesting addition to the 1-1 exchange set of answers
function localSearch(x0, objective, constraints)

    currSol = deepcopy(x0) #Best solution ATM
    m,n = size(constraints) #m is the number of constraints, n is the number of variables
    #println("x0 = ", x0, "\n")
    for i=1:n
        if x0[i] == 1
            changeI = i; #Save first position to modify
            for j=1:n
                if i!=j && x0[j] == 0
                    #println("i = ", changeI, ", j = ", j)
                    tmpSol = deepcopy(x0)
                    tmpSol[changeI] = 0; tmpSol[j] = 1
                    valid = true #becomes false if a constraint is violated, stopping constraint checking
                    validI = 1; validJ = 1;
                    #println("x1 = ",tmpSol)
                    
                    while valid == true && validI <= m
                        test = 0 #Variable to increment to check the constraint
                        validJ = 1
                        while valid == true && validJ <= n
                            #println("m = ", validI,", n = ", validJ, ", test = ", test)
                            test += tmpSol[validJ]*constraints[validI,validJ]
                            if test > 1
                                valid = false
                                #println("TEST FAILED !", "\n")
                            end
                            validJ += 1
                        end
                        validI += 1
                    end

                    #The use of >= is meant to change the next neighbourhood even in case of a tie between solutions
                    if dot(tmpSol,objective) >= dot(currSol,objective) && valid
                        #println("IMPROVED SOLUTION !")
                        currSol = deepcopy(tmpSol)
                    end
                end
            end
        end
    end

    return currSol

end
