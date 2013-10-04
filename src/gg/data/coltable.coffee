#<< gg/data/table

class gg.data.ColTable extends gg.data.Table
  @ggpackage = "gg.data.ColTable"

  constructor: (@schema, @cols=null) ->
    unless @cols?
      @cols = _.times @schema.ncols(), ()->[]
    @log = gg.data.Table.log

  nrows: -> 
    if @cols.length == 0 then 0 else @cols[0].length
  ncols: -> @cols.length

  cloneShallow: ->
    cols = _.map @cols, (col) -> _.clone col
    new gg.data.ColTable @schema.clone(), cols

  cloneDeep: -> @cloneShallow()

  addConstColumn: (col, val, type=null) ->
    if @schema.has col
      throw Error "#{col} already exists in schema #{@schema.toString()}"
    
    type = gg.data.Schema.type(val) unless type?
    @schema.addColumn col, type
    idx = @schema.index col
    @cols[idx] = _.times(@nrows(), () -> val)

  addColumn: (col, vals, type=null) ->
    if @schema.has col
      throw Error "#{col} already exists in schema #{@schema.toString()}"
    if vals.length != @nrows()
      throw Error "vals length != table length.  #{vals.length} != #{@nrows()}"

    unless type?
      type = if vals.length == 0 
        gg.data.Schema.unknown
      else
        gg.data.Schema.type vals[0]

    @schema.addColumn col, type
    @cols[@schema.index col] = vals
    @


  addRow: (raw) ->
    row = gg.data.Row.toRow raw, @schema
    for col in @schema.cols
      @cols[@schema.index(col)].push row.get(col)

  get: (idx, col=null) ->
    if col?
      @cols[@schema.index(col)][idx]
    else
      rowdata = _.map @cols, (coldata) => coldata[idx]
      new gg.data.Row rowdata, @schema

  getCol: (col) -> @getColumn col
  getColumn: (col) -> @cols[@schema.index col]

  raw: ->
    _.times @nrows(), (i) => 
      _.o2map @schema.cols, (col) => [col, @cols[@schema.index(col)][i]]

  @fromArray: (rows) ->
    schema = gg.data.Schema.infer rows
    cols = _.times schema.ncols(), () -> []
    for row in rows
      for col in schema.cols
        if col of row
          cols[schema.index col].push row[col]
        else
          cols[schema.index col].push null
    new gg.data.ColTable schema, cols

  @fromJSON: (json) ->
    schema = gg.data.Schema.fromJSON json.schema
    t = new gg.data.ColTable schema
    for raw in json.data
      t.addRow raw
    t




