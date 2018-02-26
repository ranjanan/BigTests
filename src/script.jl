# Export useful functions
export bench, run_python,
        run_julia, run_julia_single, 
        run_julia_cholmod


# Declare constants to record time
const t_py = Float64[]
const t_jul = Float64[]
const t_jul_sing = Float64[]
const t_jul_chol = Float64[]

function bench(str; printing::Bool = true, kind::String = "1solve")
    !contains(pwd(), str) && cd(joinpath(Pkg.dir(), "BigTests", "data", str))
    file = "$(str)-$(kind).ini"
    t1, r1 = run_python(file, printing = printing)
    t2, r2 = run_julia(file, printing = printing)
    @show sum(abs2, r2 - r1)
    t3, r3 = run_julia_single(file, printing = printing)
    @show sum(abs2, r3 - r1)
    t4, r4 = run_julia_cholmod(file, printing = printing)
    @show sum(abs2, r4 - r1)
    push!(t_py, t1)
    push!(t_jul, t2)
    push!(t_jul_sing, t3)
    push!(t_jul_chol, t4)
end

# Python kernel
function run_python(file; printing::Bool = true)
    if !isfile(file)
        s = split(file, '-')[1]
        cd(joinpath(Pkg.dir(), "BigTests", "data", s))
    end
    t1 = @elapsed begin
        c = cs.Compute(file, "Screen")
        r1 = c[:compute]()
    end
    printing && println("Python time = $t1")
    t1, r1[1]
end

# Julia kernel
function run_julia(file; printing::Bool = true) 
    if !isfile(file)
        s = split(file, '-')[1]
        cd(joinpath(Pkg.dir(), "BigTests", "data", s))
    end
    t2 = @elapsed r2 = compute(file)
    printing && println("Julia time = $t2")
    t2, r2
end

# Julia single precision kernel
function run_julia_single(file; printing::Bool = true)
    if !isfile(file)
        s = split(file, '-')[1]
        cd(joinpath(Pkg.dir(), "BigTests", "data", s))
    end
    t3 = @elapsed r3 = compute_single(file)
    printing && println("Julia single precision time = $t3")
    t3, r3
end

# Julia cholmod time
function run_julia_cholmod(file; printing::Bool = true)
    if !isfile(file)
        s = split(file, '-')[1]
        cd(joinpath(Pkg.dir(), "BigTests", "data", s))
    end
    t4 = @elapsed r4 = compute_cholmod(file)
    printing && println("Julia cholmod time = $t4")
    t4, r4
end

warmup() = bench("1m", printing = false)

function runall(kind = "1solve")
    info("Warmup computation")
    warmup()
    if kind == "all"
        bench("1m", kind = "all")
    end
    info("Warmup done!")
    for str in ["1m", "6m", "12m", "24m", "48m", "96m"]
        info("Benchmarking Problem of Size $str")
        bench(str, kind = kind)
    end
end

