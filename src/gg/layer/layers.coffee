#<< gg/util/util
#<< gg/layer/layer
#<< gg/layer/shorthand

class gg.layer.Layers
  @ggpackage = "gg.layer.Layers"

  constructor: (@g, @spec) ->
    @layers = []
    @log = gg.util.Log.logger @constructor.ggpackage, "Layers"
    @parseSpec()

  parseSpec: ->
    _.each @spec, (layerspec) => @addLayer layerspec

  # @return [ [node,...], ...] a list of nodes for each layer
  compile: ->
    _.map @layers, (l) =>
      nodes = l.compile()
      nodes

  getLayer: (layerIdx) ->
    if layerIdx >= @layers.length
      throw Error("Layer with idx #{layerIdx} does not exist.
        Max layer is #{@layers.length}")
    @layers[layerIdx]

  get: (layerIdx) -> @getLayer layerIdx

  addLayer: (layerOrSpec) ->
    layerIdx = @layers.length

    if _.isType layerOrSpec, gg.layer.Layer
      layer = layerOrSpec
    else
      spec = _.clone layerOrSpec
      spec.layerIdx = layerIdx
      layer = gg.layer.Layer.fromSpec @g, spec

    layer.layerIdx = layerIdx
    @layers.push layer







