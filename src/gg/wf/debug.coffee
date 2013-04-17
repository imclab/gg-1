#<< gg/wf/node

class gg.wf.Stdout extends gg.wf.Exec
  constructor: (@spec={}) ->
    super @spec

    @type = "stdout"
    @name = findGood [@spec.name, "#{@type}-#{@id}"]
    @n = findGood [@spec.n, null]

  compute: (table, env, node) ->
    n = if @n? then @n else table.nrows()
    blockSize = Math.max(Math.floor(table.nrows() / n), 1)
    idx = 0
    @log "Stdout Schema: #{table.colNames()}"
    while idx < table.nrows()
      row = table.get(idx)
      raw = _.clone row.raw()
      _.each raw, (v, k) ->
        raw[k] = v[0..4] if _.isArray v
      str = JSON.stringify raw
      @log "Stdout: #{str}"
      idx += blockSize
    table



class gg.wf.Scales extends gg.wf.Exec
  constructor: (@spec={}) ->
    super @spec

    @type = "scaleout"
    @name = findGood [@spec.name, "#{@type}-#{@id}"]
    @scales = @spec.scales

  compute: (table, env, node) ->
    scales = @scales.scalesList[0]
    _.each scales.aesthetics(), (aes) =>
      str = scales.scale(aes).toString()
      @log "ScaleOut: #{str}"
    table




###
gg.wf.Stdout = gg.wf.Node.klassFromSpec
  type: "stdout"
  f: (table, env, node) ->
    table.each (row, idx) =>
      if @n is null or idx < @n
        str = JSON.stringify(_.omit(row, ['get', 'ncols']))
        @log "Stdout: #{str}"
    table





gg.wf.Scales = gg.wf.Node.klassFromSpec
  type: "scaleout"
  f: (table, env, node) ->
    scales = @scales.scalesList[0]
    _.each scales.aesthetics(), (aes) =>
      str = scales.scale(aes).toString()
      @log "ScaleOut: #{str}"
    table

###
