#<< gg/util/*

try
  events = require 'events'
catch error
  console.log error

#
# Implements a generic processing node that doesn't run
#
#
# Specification
#
# {
#   name: {String}
#   params: Params or Object
# }
#
# Compute 
#
# The @compute function that external users provide are of the following signature:
#
#   (inputs, params) -> table(s)
#
# The inputs data structure is a nested array of gg.wf.Data objects.
#
class gg.wf.Node extends events.EventEmitter
  @ggpackage = "gg.wf.Node"
  @type = "node"
  @id: -> gg.wf.Node::_id += 1
  _id: 0


  constructor: (@spec={}) ->
    @flow = @spec.flow or null
    @inputs = []
    @type = @constructor.type
    @id = gg.wf.Node.id()
    @nChildren = @spec.nChildren or 0
    @nParents = @spec.nParents or 0
    @location = @spec.location or "client" # or "server"

    #
    # User specified properties
    #
    @name = @spec.name or "#{@type}-#{@id}"
    @params = new gg.util.Params @spec.params
    @params.ensure "klassname", [], @constructor.ggpackage
    logname = "#{@constructor.name}: #{@name}-#{@id}"
    @log = gg.util.Log.logger @constructor.ggpackage, logname


    @parseSpec()

  parseSpec: -> 
    @params.ensure 'keys', ['key'], null
    @params.ensure 'compute', ['f'], null


  # inputs is an array, one for each parent
  setup: (@nParents, @nChildren) ->
    @inputs = _.times @nParents, () -> null

  # not ready until every input slot is filled
  ready: -> _.all @inputs, (input) -> input?
  nReady: -> _.compact(@inputs).length

  setInput: (idx, input) -> @inputs[idx] = input

  # Output a result and call the appropriate handlers using @emit
  # @param outidx output port
  # @param data nested array of gg.wf.Data objects
  output: (outidx, tableset) ->
    @emit outidx, @id, outidx, tableset
    @emit "output", @id, outidx, tableset

    #
    # this block is all debugging code
    #
    listeners = @listeners outidx
    @log.info "output: port(#{outidx}), sizes: #{tableset.left().nrows()}"
    @debugTSet tableset

  debugTSet: (tableset) ->
    table = tableset.left().cache()
    md = tableset.right().cache()
    table.name = "data-#{@name}"
    md.name = "md-#{@name}"

    counter = new ggutil.Counter()
    total = 0
    table.dfs (n, path) ->
      name = n.constructor.name
      counter.inc("#{name}-count")
      counter.inc("#{n.name}-count")
      for key in n.timer().names()
        counter.inc(key, n.timer().sum(key))
        total += n.timer().sum(key)
    pairs = []
    counter.each (v,k) -> pairs.push [k, v]
    pairs.sort (o1, o2) -> o2[1] - o1[1]

    if total > 1000
      console.log ">> #{@name}\t#{total}"
      console.log table.graph()
      _.each pairs, (pair) ->
        console.log "#{pair[0]}\t#{pair[1]}"
      console.log "\n"

    tableset.left table.disconnect()
    tableset.right md.disconnect()
    tableset


  error: (err) -> 
    err = Error(err) if _.isString err
    @emit "error", err

  pstore: -> gg.prov.PStore.get @flow, @

  # Convenienc method to check if this is a barrier
  isBarrier: -> @type in ["barrier", 'block']

  #
  # The calling function is responsible for calling ready
  # run() will check if node is ready, but will throw an Error if so
  #
  run: -> throw Error("gg.wf.Node.run not implemented")

  compile: -> [@]

  @create: (compute, params, name) ->
    params ?= {}
    params = new gg.util.Params params
    params.put 'compute', compute
    class Klass extends @
    ret = new Klass
      name: name
      params: params
    ret



  ###############
  #
  # The following are serialization and deserialization methods
  #
  ###############

  @fromJSON: (json) ->
    klassname = json.klassname
    klass = _.ggklass klassname
    spec =
      name: json.name
      nChildren: json.nChildren
      nParents: json.nParents
      location: json.location
      params: gg.util.Params.fromJSON json.params
    o = new klass spec
    o.id = json.id if json.id?
    o

  # XXX: may lose SVG and other non-clonable parameters!!
  toJSON: ->
    reject = (o) -> o? and (o.ENTITY_NODE? or o.jquery? or o.selectAll?)
    {
      klassname: @constructor.ggpackage
      id: @id
      name: @name
      nChildren: @nChildren
      nParents: @nParents
      location: @location
      params: @params.toJSON(reject)
    }


  clone: (keepid=no) ->
    spec =
      name: @name
      nChildren: @nChildren
      nParents: @nParents
      location: @location
      params: @params.clone()
      flow: @flow
    o = new @constructor spec
    o.id = @id if keepid
    o

