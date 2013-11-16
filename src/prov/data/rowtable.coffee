#<< gg/data/table

# stores table as a list of arrays and a schema
class gg.data.RowTable extends gg.data.Table
  @ggpackage = "gg.data.RowTable"

  constructor: (@schema, rows=[]) ->
    throw Error("schema not present") unless @schema?
    rows ?= []
    @rows = []
    _.each rows, (row) => @addRow row
    @log = gg.data.Table.log

  nrows: -> @rows.length
  klass: -> gg.data.RowTable

  iterator: ->
    class Iter
      constructor: (@table) ->
        @schema = @table.schema
        @nrows = @table.nrows()
        @idx = 0
      reset: -> @idx = 0
      next: ->
        throw Error("no more elements.  idx=#{@idx}") unless @hasNext()
        @idx += 1
        new gg.data.Row @schema, @table.rows[idx]
      hasNext: -> @idx < @nrows
      close: -> @table = @schema = null
    new Iter @


  # more efficient version of each, allocates single
  # data.Row object for entire iteration and minimizes 
  # copies
  fastEach: (f, n=null) ->
    row = new gg.data.Row @schema
    ret = []
    for raw, idx in @rows
      row.data = raw
      ret.push f(row, idx)
      break if n? and idx >= n
    ret

  # internal method
  _addColumn: (col, vals) ->
    unless @has col
      throw Error("col should be in the schema: #{col}")
    colidx = @schema.index col
    for row, rowidx in @rows
      row[colidx] = vals[rowidx]
    @

  _getColumn: (col) ->
    idx = @schema.index col
    _.map @rows, (row) -> row[idx]

  _rmColumn: (col) ->
    return @ unless @has col
    rmidx = @schema.index col
    for row in @rows
      row.splice rmidx, 1

    @schema = @schema.exclude col
    @


  # Adds array, {}, or Row object as a row in this table
  #
  # @param row { } object or a gg.data.Row
  # @param pad if argument is an array of value, should we pad the end with nulls
  #        if not enough values
  # @return self
  addRow: (row, pad=no) ->
    unless row?
      throw Error "adding null row"

    if _.isArray(row)
      row = _.clone row
      unless row.length == @schema.ncols()
        if row.length > @schema.ncols() or not pad
          throw Error "row len wrong: #{row.length} != #{@schema.length}"
        else
          for i in [0...(@schema.ncols()-row.length)]
            row.push null
    else if _.isType row, gg.data.Row
      row = _.map @cols(), (col) -> row.get(col)
    else if _.isObject row
      row = _.map @cols(), (col) -> row[col]
    else
      throw Error "row type(#{row.constructor.name}) not supported" 

    @rows.push row
    @

  # return a list of {} objects
  raw: -> 
    _.map @rows, (r) => 
      o = {}
      for col in @schema.cols
        o[col] = r[@schema.index col]
      o

  serialize: ->
    JSON.stringify
      data: _.toJSON(@rows)
      schema: JSON.stringify(@schema.toJSON())
      type: 'row'

  @deserialize: (json) ->
    raws = _.fromJSON json.data
    schema = gg.data.Schema.fromJSON JSON.parse(json.schema)
    t = new gg.data.RowTable schema
    t.rows = raws
    t


  # Infers a schema from inputs and returns a row table object
  # @param rows list of { } objects
  @fromArray: (rows, schema=null) ->
    schema ?= gg.data.Schema.infer rows
    if rows? and _.isType(rows[0], gg.data.Row)
      rows = _.map rows, (row) ->
        _.map schema.cols, (col) -> row.get(col)
    else
      rows = _.map rows, (o) ->
        _.map schema.cols, (col) -> o[col]
    new gg.data.RowTable schema, rows


  @fromJSON: (json) ->
    schemaJson = json.schema
    dataJson = _.fromJSON json.data

    schema = gg.data.Schema.fromJSON schemaJson
    rows = []
    for raw in dataJson
      rows.push(gg.data.Row.toRow raw, schema)
    new gg.data.RowTable schema, rows




