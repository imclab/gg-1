#<< gg/scale/scale
#<< gg/scale/categorical

class gg.scale.ColorCont extends gg.scale.Scale
  @ggpackage = 'gg.scale.ColorCont'
  @aliases = "color_cont"
  constructor: (@spec={}) ->
    @d3Scale = d3.scale.linear()
    super

  parseSpec: ->
    super

    @startColor = @spec.startColor or d3.rgb 255, 247, 251
    @endColor = @spec.endColor or d3.rgb 2, 56, 88
    @d3Scale.range [@startColor, @endColor]

  # read only
  range: -> @d3Scale.range()



class gg.scale.Color extends gg.scale.BaseCategorical
  @ggpackage = 'gg.scale.Color'
  @aliases = "color"

  constructor: (@spec={}) ->
    super
    @d3Scale = d3.scale.category10() unless @rangeSet
    @invertScale = d3.scale.ordinal()
    @invertScale.domain(@d3Scale.range()).range(@d3Scale.domain())
    @type = data.Schema.ordinal


  invert: (v) -> @invertScale v



