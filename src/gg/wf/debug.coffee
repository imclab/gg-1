#<< gg/wf/node

class gg.wf.Stdout extends gg.wf.Exec
  constructor: (@spec={}) ->
    super @spec

    @type = "stdout"
    @name = findGood [@spec.name, "#{@type}-#{@id}"]
    @n = findGood [@spec.n, null]
    @aess = @spec.aess or null

  compute: (table, env, node) ->
    n = if @n? then @n else table.nrows()
    blockSize = Math.max(Math.floor(table.nrows() / n), 1)
    idx = 0
    @log "Schema: #{table.colNames()}"
    while idx < table.nrows()
      row = table.get(idx)
      row = row.project @aess if @aess?
      raw = _.clone row.raw()
      _.each raw, (v, k) ->
        raw[k] = v[0..4] if _.isArray v
      @log JSON.stringify raw
      idx += blockSize
    table



class gg.wf.Scales extends gg.wf.Exec
  constructor: (@spec={}) ->
    super @spec

    @type = "scaleout"
    @name = findGood [@spec.name, "#{@type}-#{@id}"]
    @scales = @spec.scales

  compute: (table, env, node) ->
    _.each @scales.scalesList, (scales, idx) =>
      @log "Out: scales #{scales.id}"
      _.each scales.aesthetics(), (aes) =>
        scale = scales.scale(aes)
        str = scale.toString()
        @log "Out: layer#{idx},scaleId#{scale.id} #{scale.type}\t#{str}"
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

