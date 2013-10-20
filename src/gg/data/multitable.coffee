#<< gg/data/rowtable
#<< gg/data/coltable

class gg.data.MultiTable extends gg.data.Table
  @ggpackage = "gg.data.MultiTable"

  constructor: (@schema, @tables=[]) ->
    @log = gg.data.Table.log
    @tables = _.compact @tables
    unless @schema?
      if @tables.length > 0
        @schema = gg.data.Schema.merge _.map(@tables, (t) -> t.schema)
      else
        @schema = new gg.data.Schema()


  nrows: -> _.sum @tables, (t) -> t.nrows()

  cloneShallow: ->
    ts = _.map @tables, (t) -> t.cloneShallow()
    new gg.data.MultiTable @schema.clone(), ts

  cloneDeep: ->
    ts = _.map @tables, (t) -> t.cloneDeep()
    new gg.data.MultiTable @schema.clone(), ts

  # this should really be a project
  setColumn: (col, val, type=null) ->
    tables = _.map @tables, (t) -> t.setColumn col, val, type
    new gg.data.MultiTable null, tables


  rmColumn: (col) ->
    tables = _.map @tables, (t) -> t.rmColumn col
    new gg.data.MultiTable null, tables

  addRow: (row) ->
    row = gg.data.Row.toRow row
    if @tables.length == 0
      @tables.push new gg.data.RowTable(row.schema.clone())

    _.last(@tables).addRow row
    @

  get: (idx, col=null) ->
    for t, tidx in @tables
      if idx < t.nrows()
        return t.get idx, col
      idx -= t.nrows()

  getCol: (col) -> @getColumn col
  getColumn: (col) ->
    ret = []
    for t in @tables
      ret.push.apply ret, t.getColumn(col)
    ret

  raw: ->
    ret = []
    for t in @tables
      ret.push.apply ret, t.raw()
    ret

  @fromJSON: (json) ->
    gg.data.RowTable.fromJSON json




