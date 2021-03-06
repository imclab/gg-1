#<< gg/wf/node

# General UDF operator
#
# Developer only writes a Compute function that returns a table,
# node handles the rest.
#
class gg.wf.Exec extends gg.wf.Node
  @ggpackage = "gg.wf.Exec"
  @type = "exec"

  parseSpec: ->
    @params.ensure 'compute', ['f'], null

  compute: (pairtable, params, cb) -> cb null, pairtable

  # @return emits to single child node
  run: ->
    throw Error("node not ready") unless @ready()

    params = @params
    compute = @params.get('compute') or @compute.bind(@)
    pstore = @pstore()
    log = @log

    tableset = new gg.data.TableSet @inputs
    keys = params.get 'keys'
    if keys?
      @log "partitioning on custom cols: #{keys}"
      partitions = tableset.partition keys
    else
      keys = tableset.sharedCols()
      partitions = tableset.fullPartition()
    @log "created #{partitions.length} partitions on cols #{keys}"

    iterator = (pairtable, cb) ->
      try
        compute pairtable, params, cb
      catch err
        cb err, null

    async.map partitions, iterator, (err, pairtables) =>
      throw Error(err) if err?
      pairtables = _.map pairtables, (pt) ->
        md = pt.getMD()
        t = pt.getTable()
        for col in keys
          v = md.get 0, col
          t = t.setColumn col, v
        new gg.data.PairTable t, md

      result = new gg.data.TableSet pairtables
      @output 0, result







# Assumes @compute runs synchronously and errors come from
# exceptions
#
# @compute should _not_ accept not call the callback
#
class gg.wf.SyncExec extends gg.wf.Exec
  parseSpec: ->
    super
    f = @params.get 'compute'
    f ?= @compute.bind(@)
    name = @name
    compute = (pairtable, params, cb) ->
      try
        res = f pairtable, params, () ->
          throw Error "SyncExec should not call callback"
        cb null, res
      catch err
        console.log("error in syncexec: #{name}")
        console.log(err.toString())
        cb err, null
    @params.put 'compute', compute

  compute: (pairtable, params, cb) -> pairtable



