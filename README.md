# RequestsCache.jl

WORK IN PROGRESS!!!

RequestsCache.jl is a transparent persistent cache using [Requests.jl](https://github.com/JuliaWeb/Requests.jl) library.

It's written using [Julia](http://julialang.org/).

[JLD.jl](https://github.com/JuliaLang/JLD.jl) library is used as backend.

Inspired by [requests-cache](http://requests-cache.readthedocs.org/).

## Install

```julia
Pkg.clone("https://github.com/femtotrader/RequestsCache.jl.git")
```

## Usage

```julia
import RequestsCache: create_query, execute, CachedSession, Session
import URIParser: URI
import Requests: get

session = Session()
#session = CachedSession()
session = CachedSession(cache_name="cache.jld", backend="jld", expire_after=Base.Dates.Day(1))
#println(session)

prepared_query = create_query(get, URI("http://httpbin.org/get"), query = Dict("title" => "page1"), data = "Hello World")
response = execute(prepared_query; session=session)

println(readall(response))
```
