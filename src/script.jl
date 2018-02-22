
function bench(str, printing = true)
    !contains(pwd(), str) && cd(joinpath(Pkg.dir(), "BigTests", "data", str))
    file = "$(str)-1solve.ini"
    t1 = @elapsed begin
        c = cs.Compute(file, "Screen")
        r1 = c[:compute]()
    end
    r1 = r1[1]
    t2 = @elapsed r2 = compute(file)
    t3 = @elapsed r3 = compute_single(file)
    t4 = @elapsed r4 = compute_cholmod(file)
    printing && println("Python time = $t1")
    printing && println("Julia serial time = $t2")
    printing && println("Julia single precision time = $t3")
    printing && println("Julia cholmod time = $t4")
end

warmup() = bench("1m", false)

function runall()
    info("Warmup computation")
    warmup()
    for str in ["1m", "6m", "12m", "24m", "48m", "96m"]
        info("Benchmarking Problem of Size $str")
        bench(str)
    end
end

