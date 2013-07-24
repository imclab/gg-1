#<< gg/stat/stat


class gg.stat.BoxplotStat extends gg.stat.Stat
  @ggpackage = "gg.stat.BoxplotStat"
  @aliases = ['boxplot', 'quantile']

  defaults: ->
    x: 0

  inputSchema: -> ['x', 'y']#'group']

  outputSchema: (data) ->
    table = data.table
    env = data.env
    gg.data.Schema.fromSpec
      #group: gg.data.Schema.ordinal
      #x: gg.data.Schema.ordinal
      x: table.schema.type 'x'
      q1: gg.data.Schema.numeric
      q3: gg.data.Schema.numeric
      median: gg.data.Schema.numeric
      lower: gg.data.Schema.numeric
      upper: gg.data.Schema.numeric
      outliers:
        type: gg.data.Schema.array
        schema:
          outlier: gg.data.Schema.numeric
      min: gg.data.Schema.numeric
      max: gg.data.Schema.numeric

  schemaMapping: (data, params) ->
    x: 'x'
    q1: 'y'
    q3: 'y'
    median: 'y'
    lower: 'y'
    upper: 'y'
    outlier: 'y'
    min: 'y'
    max: 'y'

  computeStatistics: (vals) ->
    vals.sort d3.ascending

    q1 = d3.quantile vals, 0.25
    median = d3.quantile vals, 0.5
    q3 = d3.quantile vals, 0.75
    min = if vals.length then vals[0] else null
    max = if vals.length then vals[vals.length - 1] else null
    fr = 1.5 * (q3-q1)
    lowerIdx = d3.bisectLeft vals, q1 - fr
    upperIdx = (d3.bisectRight vals, q3 + fr, lowerIdx) - 1
    lower = vals[lowerIdx]
    upper = vals[upperIdx]
    outliers = vals.slice(0, lowerIdx).concat(vals.slice(upperIdx + 1))

    outliers = _.map outliers, (v) -> {outlier: v}

    {
      q1: q1,
      median: median,
      q3: q3,
      lower: lower,
      upper: upper,
      outliers: outliers,
      min: min,
      max: max
    }


  compute: (data, params) ->
    table = data.table
    env = data.env
    #groups = table.split "group"
    groups = table.split "x"
    rows = _.map groups, (groupPair) =>
      gTable = groupPair.table
      gKey = groupPair.key
      vals = gTable.getColumn "y"
      row = @computeStatistics vals
      row.x = gKey
      row

    schema = params.get('outputSchema') data, params
    data.table = new gg.data.RowTable schema, rows
    data



