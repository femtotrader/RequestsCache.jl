using Base.Test

import RequestsCache: Session, CachedSession
#import RequestsCache: create_query, execute
import RequestsCache: get

#session = Session()
#session = CachedSession()
session = CachedSession(cache_name="cache.jld", backend="jld", expire_after=Base.Dates.Day(1))
#println(session)

#prepared_query = create_query("GET", "http://httpbin.org/get", query = Dict("title" => "page1"))
#response = execute(prepared_query; session=session)

response = get(session, "http://httpbin.org/get"; query = Dict("title" => "page1"))

parsed_resp = Requests.json(response)
@test parsed_resp["args"]["title"] == "page1"
@test parsed_resp["headers"]["Host"] == "httpbin.org"

response = get(session, "http://httpbin.org/get"; query = Dict("title" => "page1"))

parsed_resp = Requests.json(response)
@test parsed_resp["args"]["title"] == "page1"
@test parsed_resp["headers"]["Host"] == "httpbin.org"
