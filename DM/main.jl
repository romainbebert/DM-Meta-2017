# =========================================================================== #

# Using the following packages
using JuMP, GLPKMathProgInterface

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
include("pacman.jl")
include("localSearch.jl")
include("GRASP.jl")

# =========================================================================== #

# Setting the data
fname = "/home/bebito/FAC/M1ORO/Metaheuristiques/DM/Data/didactic.dat"  # TODO: change back to the path for a standard config on macOS
cost, matrix = loadSPP(fname)

# Proceeding to the optimization
solverSelected = GLPKSolverMIP()
ip, ip_x = setSPP(solverSelected, cost, matrix)
println("Solving..."); @time solve(ip)

# Displaying the results
println("z  = ", getobjectivevalue(ip))
print("x  = "); println(getvalue(ip_x))

# =========================================================================== #

# Collecting the names of instances to solve
target = "/home/bebito/FAC/M1ORO/Metaheuristiques/DM/Data"  # path for a standard config on macOS
fnames = getfname(target)

#Solves the SPP using a first heuristic then executing a localSearch twice to get neighbouring solutions to improve x0 using k-p exchanges
function approxSolve(objective,matrix)

    x0 = pacman(objective, matrix) #pacman returns a solution of the SPP using a heuristic
    x1 = localSearch(x0, objective, matrix) #this instance is then improved twice by a k-p exchange method
    x2 = localSearch(x1, objective, matrix)

    result = 0
    res0 = 0
    n = size(objective,1)

    for j=1:n
        res0 += x0[j]*objective[j]
    end

    for j=1:n
        result += x2[j]*objective[j]
    end

    println("z0 = ", res0)

    return x2, result

end

function launchGRASP(objective,matrix, alpha, budget)

    m,n = size(matrix)
    results = []

    for i = 1:budget
        xprec = GRASP(objective, matrix, alpha) #Alpha is a slider between 0 and 1 to give a level of randomness
        xres = localSearch(xprec, objective, matrix) #this instance is then improved twice by a k-p exchange method

        res0 = 0
        res1 = 0

        while res0 != res1
            xprec = xres
            xres = localSearch(xprec, objective, matrix)

            res0 = 0
            res1 = 0
            
            for j=1:n
                res0 += xprec[j]*objective[j]
            end

            for j=1:n
                res1 += xres[j]*objective[j]
            end

            println("xprec : ", res0, ", xres : ", res1)

        end


        result = 0
        res0 = 0
        n = size(objective,1)

        for j=1:n
            result += xres[j]*objective[j]
        end

        push!(results, result)

    end

    tot=0

    for z in results
        tot+=z
    end

    zavg = tot/budget
    sort!(results)
    zmin = results[1]
    zmax = results[budget]

    return zmin, zavg, zmax

end

#=
function launchrGRASP(objective,matrix)

    x0 = rGRASP(objective, matrix, m, N) #m number of random alphas updated after N iterations
    x1 = localSearch(x0, objective, matrix) #this instance is then improved twice by a k-p exchange method
    x2 = localSearch(x1, objective, matrix)

    result = 0
    res0 = 0
    n = size(objective,1)

    for j=1:n
        res0 += x0[j]*objective[j]
    end

    for j=1:n
        result += x2[j]*objective[j]
    end

    println("z0 = ", res0)

    return x2, result

end
=#

function launchDM1()

    for (instance) in fnames

        objective, matrix = loadSPP(instance)

        println("time for solving instance ", instance, " using heuristics : ")
        @time sol,obj = approxSolve(objective,matrix) #sol is the value of the variables and obj is the result of the objective function
        println("z = ", obj)
        #println("x = ", sol)

    end

end

function launchDM2(alpha, budget)

    for (instance) in fnames

        objective, matrix = loadSPP(instance)

        println("time for solving instance ", instance, " using heuristics : ")
        @time zmin, zavg, zmax = launchGRASP(objective,matrix, alpha, budget) #sol is the value of the variables and obj is the result of the objective function
        println("zmin = ", zmin, ", zavg = ", zavg, ", zmax = ", zmax)
        #println("x = ", sol)

    end

end

function launchDM2r()

    for (instance) in fnames

        objective, matrix = loadSPP(instance)

        println("time for solving instance ", instance, " using heuristics : ")
        @time zmin, zavg, zmax = launchrGRASP(objective,matrix) #sol is the value of the variables and obj is the result of the objective function
        println("z = ", obj)
        #println("x = ", sol)

    end

end

#Here for the sake of time comparison
function completeSolver()

    for (instance) in fnames

        objective, matrix = loadSPP(instance)

        println("time for solving instance ", instance, " GLPK solver : ")
        ip, ip_x = setSPP(solverSelected, objective, matrix)
        println("Solving..."); @time solve(ip)

        # Displaying the results
        println("z  = ", getobjectivevalue(ip))
        #print("x  = "); println(getvalue(ip_x)) #Commented because too verbose
        ip,ip_x = (0,0)
        
    end

end

#Here for the sake of time comparison
function completeSolver(timeLim)

    solverSelected = GLPKSolverMIP( tm_lim=60000)

    for (instance) in fnames

        objective, matrix = loadSPP(instance)

        println("time for solving instance ", instance, " GLPK solver : ")
        ip, ip_x = setSPP(solverSelected, objective, matrix)
        println("Solving..."); @time solve(ip)

        # Displaying the results
        println("z  = ", getobjectivevalue(ip))
        #print("x  = "); println(getvalue(ip_x)) #Commented because too verbose
        ip,ip_x = (0,0)
        
    end

end

