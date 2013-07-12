#<< gg/wf/node




# Opposite of Split
#
# Does not compute anything
class gg.wf.Merge extends gg.wf.Node
  @ggpackage = "gg.wf.Merge"
  @type = "merge"

  parseSpec: ->
    @params.ensureAll
      envkey: ['key', 'envkey']
      attr: ['attr', 'key', 'envkey']
      default: ['default']

  compute: (datas, params) ->
    return datas if datas.length <= 1
    envkey = params.get 'envkey'
    defaultVal = params.get 'default'
    attr = params.get 'attr'

    @log "Merge node tables and envs"

    _.each datas, (data) ->
      table = data.table
      env = data.env
      val =
        if env.contains(envkey)
          env.get(envkey)
        else
          defaultVal

      if table.contains attr
        if table.schema.isArray attr
          # XXX: attr better not be an array type!
          throw Error("Merge doesn't support setting array types")
        table.each (row) -> row.set attr, val
      else
        table.addConstColumn attr, val

    tables = _.map datas, (d) -> d.table
    table = gg.data.Table.merge tables
    new gg.wf.Data table, _.first(datas).env


  run: ->
    unless @ready()
      throw Error("#{@name} not ready: #{@inputs.length} of #{@children().length} inputs")

    params = @params
    compute = @params.get 'compute'
    pstore = @pstore()
    f = (datas, outpath) =>
      # write provenance
      for data, lastIdx in datas
        inpath = _.clone outpath
        inpath.push lastIdx
        pstore.writeData outpath, inpath

      @compute datas, params

    outputs = gg.wf.Inputs.mapLeafArrays @inputs, f

    for output, idx in outputs
      @output idx, output
    outputs


