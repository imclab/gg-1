#<< gg/pos/position


class gg.pos.Jitter extends gg.core.XForm
  @ggpackage = "gg.pos.Jitter"
  @aliases = "jitter"

  inputSchema: -> ['x', 'y']

  parseSpec: ->
    super
    scale = _.findGood [@spec.scale, 0.2]
    xScale = _.findGood [@spec.xScale, @spec.x, null]
    yScale = _.findGood [@spec.yScale, @spec.y, null]
    if xScale? or yScale?
      xScale = xScale or 0
      yScale = yScale or 0
    else
      xScale = yScale = scale

    @params.putAll
      xScale: xScale
      yScale: yScale

  compute: (pairtable, params) ->
    table = pairtable.getTable()
    md = pairtable.getMD()
    scales = md.get 0, 'scales'
    schema = table.schema
    map = [] 
    Schema = gg.data.Schema

    if schema.type('x') is Schema.numeric
      xRange = scales.scale("x", Schema.unknown).range()
      xScale = (xRange[1] - xRange[0]) * params.get('xScale')
      map.push [
        'x'
        (v) -> v + (0.5 - Math.random()) * xScale
        Schema.numeric
      ]

    if schema.type('y') is Schema.numeric
      yRange = scales.scale("y", Schema.unknown).range()
      yScale = (yRange[1] - yRange[0]) * params.get('yScale')
      map.push [
        'y'
        ((v) -> v + (0.5 - Math.random()) * yScale),
        Schema.numeric
      ]

    table = gg.data.Transform.mapCols table, map 
    new gg.data.PairTable table, md


