###
client.coffee
author: @ecoslado
2015 04 01
###

httpLib = require "http"
httpsLib = require "https"
md5 = require "md5"

###
DfClient
This class is imported with module
requirement. Implements the search request
and returns a json object to a callback function
###

class Client
  ###
  Client constructor

  @param {String} hashid
  @param {String} apiKey
  @param {String} version
  @param {String} address
  @api public
  ###
  constructor: (@hashid, apiKey, version, @type, address) ->
    @version ?= version
    @version ?= 5
    @params = {}
    @filters = {}

    @url ?= address
    # API Key can be two ways:
    # zone-APIKey
    # zone
    # We check if there is a -
    if apiKey
      zoneApiKey = apiKey.split('-')
      zone = zoneApiKey[0]
      if zoneApiKey.length > 1
        @apiKey = zoneApiKey[1]

    else
      zone = ""
      @apiKey = ""

    @secured = @apiKey? and @version != 4

    @url ?= zone + "-search.doofinder.com"

  ###
  _sanitizeQuery
  very crude check for bad intentioned queries

  checks if words are longer than 55 chars and the whole query is longer than 255 chars
  @param string query
  @return string query if it's ok, empty space if not
  ###
  _sanitizeQuery: (query, callback) ->
    maxWordLength = 55
    maxQueryLength = 255
    if typeof(query) == "undefined"
      throw Error "Query must be a defined"

    if query == null or query.constructor != String
      throw Error "Query must be a String"

    query = query.replace(/ +/g, ' ').replace(/^ +| +$/g, '') # query.trim() is ECMAScript5

    if query.length > maxQueryLength
      throw Error "Maximum query length exceeded: #{maxQueryLength}."

    for i, x of query.split(' ')
      if x.length > maxWordLength
        throw Error "Maximum word length exceeded: #{maxWordLength}."

    return callback query


  ###
  search

  Method responsible of executing call.

  @param {Object} params
    i.e.:

      query: "value of the query"
      page: 2
      rpp: 25
      filters:
        brand: ["nike", "adidas"]
        color: ["blue"]
        price:
          from: 40
          to: 150

  @param {Function} callback (err, res)
  @api public
  ###
  search: (query, arg1, arg2) ->

    # Managing different ways of
    # calling search

    # dfClient.search(query, callback)
    if arg1 and arg1.constructor == Function
      callback = arg1
      params = {}

    # dfClient.search(query, params, callback)
    else if arg1 and arg2 and arg1.constructor == Object
      callback = arg2
      params = arg1

    # Wrong call
    else
      throw new Error "A callback is required."

    # Set default params
    params.page ?= 1
    params.rpp ?= 10

    # Add query to params
    _this = @

    @_sanitizeQuery query, (cleaned) ->
      params.query = cleaned
      headers = {}
      if _this.apiKey
        headers[_this.__getAuthHeaderName()] = _this.apiKey

      _this.params = {}
      _this.filters = {}
      _this.sort = []

      for paramKey, paramValue of params
        if paramKey == "filters"
          for filterKey, filterTerms of paramValue
            _this.addFilter(filterKey, filterTerms)

        else if paramKey == "sort"
          _this.setSort(paramValue)

        else
          _this.addParam(paramKey, paramValue)

      queryString = _this.makeQueryString()
      path = "/#{_this.version}/search?#{queryString}"

      # Preparing request variables

      options = _this.__requestOptions(path)

      # Here is where request is done and executed processResponse
      req = _this.__makeRequest options, callback
      req.end()

  ###
  addParam

  This method set simple params
  @param {String} name of the param
  @value {mixed} value of the param
  @api public
  ###

  addParam: (param, value) ->
    if value != null
      @params[param] = value
    else
      @params[param] = ""

  ###
  addFilter

  This method adds a filter to query
  @param {String} filterKey
  @param {Array|Object} filterValues
  @api public
  ###
  addFilter: (filterKey, filterValues) ->
    @filters[filterKey] = filterValues

  ###
  setSort

  This method adds sort to object
  from an object or an array

  @param {Array|Object} sort
  ###
  setSort: (sort) ->
    @sort = sort


  ###
  __escapeChars

  This method encodes just the chars
  like &, ?, #.

  @param {String} word
  ###
  __escapeChars: (word) ->
    word = word.replace(/\&/, "%26")
    word = word.replace(/\?/, "%3F")
    word = word.replace(/\+/, "%2B")
    return word.replace(/\#/, "%23")

  ###
  makeQueryString

  This method returns a
  querystring for adding
  to Search API request.

  @returns {String} querystring
  @api private
  ###
  makeQueryString: () ->
    # Adding hashid
    querystring = encodeURI "hashid=#{@hashid}"

    # Adding types
    if @type and @type instanceof Array
      for key, value of @type
        querystring += encodeURI "&type=#{value}"

    else if @type and @type.constructor == String
      querystring += encodeURI "&type=#{@type}"

    # Adding params
    for key, value of @params
      querystring += encodeURI "&#{key}=#{value}"

    # Adding filters
    for key, value of @filters
      # Range filters
      if value.constructor == Object
        for k, v of value
          querystring += encodeURI "&filter[#{key}][#{k}]=#{v}"

      # Terms filters
      if value.constructor == Array
        for elem in value
          # escapeChars encodes &#? characters
          # those characters that encodeURI doesn't
          segment = @__escapeChars encodeURI "filter[#{key}]=#{elem}"
          querystring += "&#{segment}"

    # Adding sort options
    # See http://doofinder.com/en/developer/search-api#sort-parameters
    if @sort and @sort.constructor == Array
      for value in @sort
        for facet, term of value
          querystring += encodeURI "&sort[#{@sort.indexOf(value)}][#{facet}]=#{term}"

    else if @sort and @sort.constructor == String
      querystring += encodeURI "&sort=#{@sort}"


    else if @sort and @sort.constructor == Object
      for key, value of @sort
        querystring += encodeURI "&sort[#{key}]=#{value}"

    return querystring

  ###
  This method calls to /stats/click
  service for accounting the
  clicks to a product

  @param {String} productId
  @param {Object} options
  @param {Function} callback

  @api public
  ###  
  registerClick: (productId, arg1, arg2) ->
    # Defaults
    callback = ((err, res) ->)
    options = {}

    # Check how many args there are
    if typeof arg2 == 'undefined' and typeof arg1 == 'function'
      callback = arg1
    else if typeof arg2 == 'undefined' and typeof arg1 == 'object'
      options = arg1  
    else if typeof arg2 == 'function' and typeof arg1 == 'object'
      callback = arg2
      options = arg1

    # doofinder internal id regex
    dfidRe = /\w{32}@[\w_-]+@\w{32}/
    # You can receive the dfid
    if dfidRe.exec(productId)
      dfid = productId
    # Or just md5(product_id)  
    else
      datatype = options.datatype || "product"
      dfid = "#{@hashid}@#{datatype}@#{md5(productId)}"
    # Optional args
    sessionId = options.sessionId || "session_id"
    query = options.query || ""
    path = "/#{@version}/stats/click?dfid=#{dfid}&session_id=#{sessionId}&query=#{encodeURIComponent(query)}"
    path += "&random=#{new Date().getTime()}"
    options = @__requestOptions(path)
    # Here is where request is done and executed processResponse
    req = @__makeRequest options, callback
    req.end()


  ###
  This method calls to /stats/init_session
  service for init a user session

  @param {String} sessionId
  @param {Function} callback

  @api public
  ###
  registerSession: (sessionId, callback=((err, res)->)) ->
    path = "/#{@version}/stats/init?hashid=#{@hashid}&session_id=#{sessionId}"
    path += "&random=#{new Date().getTime()}"
    options = @__requestOptions(path)
    req = @__makeRequest options, callback
    req.end()


  ###
  This method calls to /stats/checkout
  service for init a user session

  @param {String} sessionId
  @param {Object} options
  @param {Function} callback

  @api public
  ###
  registerCheckout: (sessionId, arg1, arg2) ->
    # Defaults
    callback = ((err, res) ->)
    options = {}

    # Check how many args there are
    if typeof arg2 == 'undefined' and typeof arg1 == 'function'
      callback = arg1
    else if typeof arg2 == 'undefined' and typeof arg1 == 'object'
      options = arg1  
    else if typeof arg2 == 'function' and typeof arg1 == 'object'
      callback = arg2
      options = arg1

    path = "/#{@version}/stats/checkout?hashid=#{@hashid}&session_id=#{sessionId}"
    path += "&random=#{new Date().getTime()}"
    reqOpts = @__requestOptions(path)
    req = @__makeRequest reqOpts, callback
    req.end()


  ###
  This method calls to /hit
  service for accounting the
  hits in a product

  @param {String} dfid
  @param {String} query
  @param {Function} callback
  @api public
  ###
  hit: (sessionId, eventType, dfid="", query = "", callback = (err, res) ->) ->
    headers = {}

    if @apiKey
      headers[@__getAuthHeaderName()] = @apiKey
    path =  "/#{@version}/hit/#{sessionId}/#{eventType}/#{@hashid}"
    if dfid != ""
      path += "/#{dfid}"
    if query != ""
      path += "/#{encodeURIComponent(query)}"

    path = "#{path}?random=#{new Date().getTime()}"
    reqOpts = @__requestOptions(path)
       
    # Here is where request is done and executed processResponse
    req = @__makeRequest reqOpts, callback
    req.end()


  ###
  This method calls to /hit
  service for accounting the
  hits in a product

  @param {String} dfid
  @param {Object | Function} arg1
  @param {Function} arg2
  @api public
  ###
  options: (arg1, arg2) ->
    callback = ((err, res) ->)
    # You can send options and callback or just the callback
    if typeof arg1 == "function" and typeof arg2 == "undefined"
      callback = arg1
    else if typeof arg1 == "object" and typeof arg2 == "function"
      options = arg1
      callback = arg2

    if typeof options != "undefined" and options.querystring
      querystring = "?#{options.querystring}"
    else
      querystring = ""

    path = "/#{@version}/options/#{@hashid}#{querystring}"
    reqOpts = @__requestOptions(path)

    # Here is where request is done and executed processResponse
    req = @__makeRequest reqOpts, callback
    req.end()

  ###
  Callback function will be passed as argument to search
  and will be returned with response body

  @param {Object} res: the response
  @api private
  ###
  __processResponse: (callback) ->
    (res) ->
      if res.statusCode >= 400
        return callback res.statusCode, null

      else
        data = ""
        res.on 'data', (chunk) ->
          data += chunk

        res.on 'end', () ->
          return callback null, JSON.parse(data)

        res.on 'error', (err) ->
          return callback err, null

  ###
  Method to make a secured or not request based on @secured

  @param (Object) options: request options
  @param (Function) the callback function to execute with the response as arg
  @return (Object) the request object.
  @api private
  ###
  __makeRequest: (options, callback) ->
    if @secured
      return httpsLib.request options, @__processResponse(callback)
    else
      return httpLib.request options, @__processResponse(callback)

  ###
  Method to make the request options

  @param (String) path: request options
  @return (Object) the options object.
  @api private
  ###
  
  __requestOptions: (path) ->
    headers = {}
    if @apiKey
        headers[@__getAuthHeaderName()] = @apiKey
    options =
        host: @url
        path: path
        headers: headers

    # Just for url with host:port
    if @url.split(':').length > 1
      options.host = @url.split(':')[0]
      options.port = @url.split(':')[1]

    return options


  ###
  Method to obtain security header name
  @return (String) either 'api token' or 'authorization' depending on version
  @api private
  ###
  __getAuthHeaderName: () ->
    if @version == 4
      return 'api token'
    else
      return 'authorization'


# Module exports
module.exports = Client
