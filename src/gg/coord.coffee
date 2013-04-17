#<< gg/xform

class gg.Coordinate extends gg.XForm
  constructor: (@layer, @spec={}) ->
    g = @layer.g if @layer?
    super g, @spec
    @parseSpec()


  @klasses: ->
    klasses = [
      gg.IdentityCoordinate,
      gg.YFlipCoordinate,
      gg.XFlipCoordinate,
      gg.FlipCoordinate
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret

  @fromSpec: (layer, spec) ->
    klasses = gg.Coordinate.klasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = findGood [spec.type, spec.pos, "identity"]

    klass = klasses[type] or gg.IdentityCoordinate

    console.log "Coordinate.fromSpec: klass #{klass.name} from spec #{JSON.stringify spec}"

    ret = new klass layer, spec
    ret

  compute: (table, env, node) -> @map table, env, node

  map: (table, env) -> throw Error("#{@name}.map() not implemented")


class gg.IdentityCoordinate extends gg.Coordinate
  @aliases = ["identity"]

  map: (table, env) ->
    scales = @scales table, env
    inverted = scales.invert table, gg.Scale.ys
    yRange = scales.scale('y').range()
    yRange = [yRange[1], yRange[0]]
    scales.scale('y').range(yRange)
    table = scales.apply table, gg.Scale.ys
    table

class gg.YFlipCoordinate extends gg.Coordinate
  @aliases = ["yflip"]

  map: (table, env) ->
    @log "map: noop"
    table

class gg.XFlipCoordinate extends gg.Coordinate
  @aliases = ["xflip"]

  map: (table, env) ->
    scales = @scales table, env
    inverted = scales.invert table, gg.Scale.xys

    xRange = scales.scale('x').range()
    xRange = [xRange[1], xRange[0]]
    scales.scale('x').range(xRange)

    yRange = scales.scale('y').range()
    yRange = [yRange[1], yRange[0]]
    scales.scale('y').range(yRange)

    @log "map: xrange: #{xRange}\tyrange: #{yRange}"

    table = scales.apply table, gg.Scale.xys

    if table.contains('x0') and table.contains('x1')
      table.each (row) ->
        x0 = row.get 'x0'
        x1 = row.get 'x1'
        row.set('x0', Math.min(x0, x1))
        row.set('x1', Math.max(x0, x1))

    table



class gg.FlipCoordinate extends gg.Coordinate
  @aliases = ["flip", 'xyflip']

  map: (table, env) ->
    scales = @scales table, env
    inverted = scales.invert table, gg.Scale.xs

    xRange = scales.scale('x').range()
    xRange = [xRange[1], xRange[0]]
    scales.scale('x').range(xRange)

    @log "map: xrange: #{xRange}"

    table = scales.apply table, gg.Scale.xs

    if table.contains('x0') and table.contains('x1')
      table.each (row) ->
        x0 = row.get 'x0'
        x1 = row.get 'x1'
        row.set('x0', Math.min(x0, x1))
        row.set('x1', Math.max(x0, x1))

    table


