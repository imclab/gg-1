#<< gg/wf/node

class gg.wf.Stdout extends gg.wf.Exec
  @ggpackage = "gg.wf.Stdout"
  @type = "stdout"

  parseSpec: ->
    @params.ensureAll
      n: [ [], null ]
      aess: [ [], null ]
    @log = gg.util.Log.logger @constructor.ggpackage, "StdOut: #{@name}-#{@id}"

  compute: (table, env, params) ->
    @log "facetX: #{env.get("facetX")}\tfacetY: #{env.get("facetY")}"
    gg.wf.Stdout.print table, params.get('aess'), params.get('n'), @log
    table

  @print: (table, aess, n, log=null) ->
    if _.isArray table
      _.each table, (t) -> gg.wf.Stdout.print t, aess, n, log

    log = gg.util.Log.logger(gg.wf.Stdout.ggpackage, "stdout") unless log?
    n = if n? then n else table.nrows()
    blockSize = Math.max(Math.floor(table.nrows() / n), 1)
    idx = 0
    schema = table.schema
    log "# rows: #{table.nrows()}"
    log "Schema: #{schema.toSimpleString()}"
    while idx < table.nrows()
      row = table.get(idx)
      row = row.project aess if aess?
      raw = row.clone().raw()
      _.each raw, (v, k) ->
        raw[k] = v[0..4] if _.isArray v

      log JSON.stringify raw
      idx += blockSize

  @printTables: (args...) -> @print args...





class gg.wf.Scales extends gg.wf.Exec
  @ggpackage = "gg.wf.Scales"
  @type = "scaleout"

  compute: (table, env, params) ->
    layerIdx = env.get 'layer'
    gg.wf.Scales.print env.get('scales'), layerIdx,  @log
    table

  # @param scales set
  @print: (scaleset, layerIdx, log=null) ->
    log = gg.util.Log.logger("scaleout") unless log?

    log "Out: scaleset #{scaleset.id}, #{scaleset.scales}"
    _.each scaleset.scalesList(), (scale) =>
      str = scale.toString()
      log "Out: layer #{layerIdx}, #{str}"



