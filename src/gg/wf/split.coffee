#<< gg/wf/node



# Generalized split function
#
# @spec.f {Function} splitting function with signature: (table) -> [ {key:, table:}, ...]
class gg.wf.Split extends gg.wf.Node
  @ggpackage = "gg.wf.Split"
  @type = "split"

  parseSpec: ->
    # TODO: support groupby functions that return an
    # array of keys.
    @params.ensureAll
      gbkeyName: [['key'], @name]
      splitFunc: [['f'], @splitFunc]

  # This method must not depend on "this"!
  # @return array of {key: String, table: gg.Table} dictionaries
  splitFunc: (table, env, params) -> [ {table: table, key: null} ]

  compute: (table, env, params) ->
    splitFunc = params.get('splitFunc')
    splitFunc = @splitFunc unless _.isFunction splitFunc
    groups = splitFunc table, env, params

    unless groups? and _.isArray groups
      str = "Non-array result from calling split function"
      throw Error str

    gbkeyName = params.get 'gbkeyName'

    @log "#{groups.length} partitions"

    datas = _.map groups, (group, idx) =>
      subtable = group.table
      key = group.key
      newData = new gg.wf.Data subtable, env.clone()
      newData.env.put gbkeyName, key
      newData

    datas


  run: ->
    unless @ready()
      str = "Split not ready, expects #{@inputs.length} inputs"
      throw Error str

    pstore = @pstore()
    f = (data, inpath) =>
      res = @compute data.table, data.env, @params
      
      # write provenance
      _.times res.length, (lastIdx) =>
        outpath = _.clone inpath
        outpath.push lastIdx
        pstore.writeData outpath, inpath

      res

    outputs = gg.wf.Inputs.mapLeaves @inputs, f
    for output, idx in outputs
      @output idx, output

    outputs



# Shorthand for non-overlapping group-by
# on table column(s)
class gg.wf.Partition extends gg.wf.Split
  @ggpackage = "gg.wf.Partition"

  constructor: ->
    super
    @name = @spec.name or "partition-#{@id}"

  splitFunc: (table, env, params) ->
    gbfunc = params.get 'f'
    gbfunc = (()->"1") unless gbfunc? and _.isFunction gbfunc
    table.split gbfunc


# Shorthand for non-overlapping group-by
# on table column(s)
class gg.wf.PartitionCols extends gg.wf.Split
  @ggpackage = "gg.wf.PartitionCols"

  constructor: ->
    super
    @name = @spec.name or "partitioncols-#{@id}"

    cols = @params.get 'cols'
    cols = [@params.get 'col'] unless cols?
    cols = _.compact _.flatten cols
    unless cols? and cols.length > 0
      @log.warn "PartitionCols running with 0 cols"
    @params.put 'cols', cols


  compute: (table, env, params) ->
    cols = params.get 'cols'
    gbkeyName = params.get 'gbkeyName'
    @log "split on cols: #{cols}"

    if not(cols? and cols[0]?)
      @log "no cols, using original table"
      data = new gg.wf.Data table, env.clone()
      data.env.put gbkeyName, null
      datas = [ data ]
      datas
    else
      f = (row) -> _.first _.map cols, ((col) -> row.get(col))
      groups = table.split f

      @log "#{groups.length} partitions"
      datas = _.map groups, (group, idx) =>
        subtable = group.table
        key = group.key
        newData = new gg.wf.Data subtable, env.clone()
        newData.env.put gbkeyName, key
        newData

      datas



