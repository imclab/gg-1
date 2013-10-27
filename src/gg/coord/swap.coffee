#<< gg/coord/coord

# The swap coordinate needs to flip the y-scale range because
# SVG and Canvas orgin is in the upper left.
class gg.coord.Swap extends gg.coord.Coordinate
  @ggpackage = "gg.coord.Swap"
  @aliases = ["swap"]

  compute: (data, params) ->
    table = data.getTable()
    scales = @scales data, params
    xtype = ytype = gg.data.Schema.unknown
    xtype = table.schema.type('x') if table.has 'x'
    ytype = table.schema.type('y') if table.has 'y'
    xScale = scales.scale 'x', xtype
    xRange = xScale.range()
    yScale = scales.scale 'y', ytype
    yRange = yScale.range()



    # invert to original domain
    # swap table xs for ys
    # swap scale x for y
    # reapply scales

    inverted = scales.invert table, gg.scale.Scale.xys
    xcols = _.o2map gg.scale.Scale.xs, (x) ->
      if inverted.has x
        [x, inverted.getColumn x]
    ycols = _.o2map gg.scale.Scale.ys, (y) ->
      if inverted.has y
        [y, inverted.getColumn y]

    for x, colData of xcols
      newcol = "y#{x.substr 1}"
      inverted = inverted.addColumn newcol, colData, xtype, yes

    for y, colData of ycols
      newcol = "x#{y.substr 1}"
      inverted = inverted.addColumn newcol, colData, ytype, yes

    # now swap the x and y scales
    xScale.range [yRange[1], yRange[0]]
    yScale.range xRange
    xScale.aes = 'y'
    yScale.aes = 'x'
    scales.set xScale
    scales.set yScale

    table = scales.apply inverted, gg.scale.Scale.xys
    new gg.data.PairTable table, data.getMD()
