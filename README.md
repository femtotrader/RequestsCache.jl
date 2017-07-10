# RequestsCache.jl

[![Package Evaluator](http://pkg.julialang.org/badges/RequestsCache_0.6.svg)](http://pkg.julialang.org/?pkg=RequestsCache)

[![Build Status](https://travis-ci.org/femtotrader/RequestsCache.jl.svg?branch=master)](https://travis-ci.org/femtotrader/RequestsCache.jl)

[![Coverage Status](https://coveralls.io/repos/femtotrader/RequestsCache.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/femtotrader/RequestsCache.jl?branch=master)

[![codecov.io](http://codecov.io/github/femtotrader/RequestsCache.jl/coverage.svg?branch=master)](http://codecov.io/github/femtotrader/RequestsCache.jl?branch=master)

RequestsCache.jl is a transparent persistent cache using [Requests.jl](https://github.com/JuliaWeb/Requests.jl) library.

It's written using [Julia](http://julialang.org/).

[JLD.jl](https://github.com/JuliaLang/JLD.jl) library is used as backend.

Inspired by [requests-cache](http://requests-cache.readthedocs.org/).

## Install

```julia
Pkg.add("RequestsCache")
```

## Usage

```julia
import RequestsCache: Session, CachedSession
import RequestsCache: get

session = Session()
#session = CachedSession()
session = CachedSession(cache_name="cache.jld", backend="jld", expire_after=Base.Dates.Day(1))
#println(session)

response = get(session, "http://httpbin.org/get", query = Dict("title" => "page1"))

println(readall(response))
```

## Projects using RequestsCache.jl
 - [DataReaders.jl](https://github.com/femtotrader/DataReaders.jl)
