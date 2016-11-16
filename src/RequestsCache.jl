__precompile__()

#=
RequestsCache
A cache mechanism for [Request.jl](https://github.com/JuliaWeb/Requests.jl)

Based on JLD https://github.com/JuliaLang/JLD.jl

Inspired by [requests-cache](http://requests-cache.readthedocs.org/).

=#

module RequestsCache

    export get, CachedSession

    import Base: read
    import Requests: do_request, do_stream_request, ResponseStream
    import URIParser: URI
    import HttpCommon: Response
    import JLD: jldopen, write

    immutable PreparedQuery
        verb::String
        uri::URI
        args::Array{Any,1}
    end
    Base.hash(q::PreparedQuery, h::UInt) = hash(string(q.verb), hash(string(q.uri), hash(q.args)))

    function create_query(verb::String, uri::URI; args...)
        return PreparedQuery(verb, uri, args)
    end
    create_query(verb::String, uri::String; args...) = create_query(verb, URI(uri); args...)

    immutable CachedSessionType
        cache_name::String
        backend::String
        expire_after
    end

    function CachedSession(; cache_name="cache.jld", backend="jld", expire_after=Base.Dates.Day(1))
        if backend == "jld"
            CachedSessionType(cache_name, backend, expire_after)
        else
            error("'$(backend)' is not a supported backend")
        end
    end

    immutable CachedResponse
        dt_stored::DateTime
        response::Response
    end

    function UTCnow()
        Dates.now(Dates.UTC)
    end

    #=
    immutable CachedResponseStream{T}
        dt_stored::DateTime
        response::ResponseStream{T}
    end

    function write(session::CachedSessionType, prepared_query::PreparedQuery, response::ResponseStream{TCPSocket})
        backend = lowercase(session.backend)
        filename = session.cache_name
        key = string(hash(prepared_query))
        cached_response = CachedResponseStream(UTCnow(), response)
        if backend == "jld"
            jldopen(filename, "w") do file
                println("Write $cached_response with key='$key' to '$filename'")
                write(file, key, cached_response)
            end
        else
            error("'$(backend)' is not a supported backend for writing")
        end
    end
    =#

    function write(session::CachedSessionType, prepared_query::PreparedQuery, response::Response)
        backend = lowercase(session.backend)
        filename = session.cache_name
        key = string(hash(prepared_query))
        cached_response = CachedResponse(UTCnow(), response)
        if backend == "jld"
            jldopen(filename, "w") do file
                println("Write $cached_response with key='$key' to '$filename'")
                write(file, key, cached_response)
            end
        else
            error("'$(backend)' is not a supported backend for writing")
        end
    end

    function read(session::CachedSessionType, prepared_query::PreparedQuery)
        backend = lowercase(session.backend)
        filename = session.cache_name
        key = string(hash(prepared_query))
        if backend == "jld"
            retrieved_response = jldopen(filename, "r") do file
                println("Read key='$key' from '$filename'")
                read(file, key)
            end
            return retrieved_response
        else
            error("'$(backend)' is not a supported backend for reading")
        end        
    end

    "Returns true if the query hash exists in the cache"
    function checkcache(session::CachedSessionType, prepared_query::PreparedQuery)
        filename = session.cache_name
        key = string(hash(prepared_query))
        res = false
        jldopen(filename, "r") do file
            res = !isempty(find(names(file) .== key))
        end
        return res
    end

    function execute_remote(prepared_query::PreparedQuery)
        println("execute_remote $(prepared_query.verb) $(prepared_query.uri) $(prepared_query.args)")
        verb = uppercase(string(prepared_query.verb))
        if !contains(verb, "_STREAMING")
            do_request(prepared_query.uri, verb; prepared_query.args...)
        else
            do_stream_request(prepared_query.uri, verb; prepared_query.args...)
        end
    end

    function execute_local(session::CachedSessionType, prepared_query::PreparedQuery, overwrite::Bool)
        println("execute_local")
        if checkcache(session,prepared_query)
            retrieved_response = read(session, prepared_query)
            dt_expiration = retrieved_response.dt_stored + session.expire_after
            if dt_expiration > UTCnow() && !overwrite
                println("Not expired")
                return retrieved_response.response
            else
                println("Cache expired - update is necessary")
                response = execute_remote(prepared_query)
                write(session, prepared_query, response)
                return response
            end
        else
            response = execute_remote(prepared_query)
            write(session, prepared_query, response)
            println("Write to $session")
            return response
        end
    end

    function execute(prepared_query::PreparedQuery; session=Session(), overwrite = false)
        println(session)
        if session.backend == ""
            execute_remote(prepared_query)
        else
            execute_local(session, prepared_query, overwrite)
        end
    end

    function clear(session::CachedSessionType)
        rm(session.cache_name)
    end

    for f in [:get, :post, :put, :delete, :head,
              :trace, :options, :patch, :connect]
        f_str = uppercase(string(f))
        @eval begin
            function ($f)(session::CachedSessionType, uri::URI, data::String; headers::Dict=Dict(), overwrite = false)
                #do_request(uri, $f_str; data=data, headers=headers)
                prepared_query = create_query($f_str, uri; data=data, headers=headers)
                response = execute(prepared_query; session=session, overwrite = overwrite)
            end

            ($f)(session::CachedSessionType, uri::String; args...) = ($f)(session, URI(uri);  args...)
            function ($f)(session::CachedSessionType, uri::URI; overwrite = false, args...)
                #do_request(uri, $f_str; args...)
                prepared_query = create_query($f_str, uri;  args...)
                response = execute(prepared_query; session=session, overwrite = overwrite)
            end
        end
    end

end


