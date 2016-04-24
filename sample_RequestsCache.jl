include("src/RequestsCache.jl")

import RequestsCache: Session, CachedSession
import RequestsCache: create_query, execute
import RequestsCache: get

session = Session()
#session = CachedSession()
session = CachedSession(cache_name="cache.jld", backend="jld", expire_after=Base.Dates.Day(1))
#println(session)

#prepared_query = create_query("GET", "http://httpbin.org/get", query = Dict("title" => "page1"))
#response = execute(prepared_query; session=session)

response = get(session, "http://httpbin.org/get"; query = Dict("title" => "page1"))

println(readall(response))