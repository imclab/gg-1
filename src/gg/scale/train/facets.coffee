#<< gg/core/bform

# Merges scale sets across facets and layers into a single
# master scale set, then merges components back to each layer's
# scale set
class gg.scale.train.Master extends gg.core.BForm
  @ggpackage = "gg.scale.train.Master"


  parseSpec: ->
    @params.ensure 'scalesTrain', [], 'fixed'

  compute: (datas, params) ->
    gg.scale.train.Master.train datas, params
    datas

  @train: (datas, params) ->
    scalesTrain = params.get('scalesTrain') or 'fixed'
    scaleSetList = gg.core.FormUtil.scalesList datas
    masterScaleSet = gg.scale.Set.merge scaleSetList
    # @expandDomains masterScaleSet
    envs = _.map datas, (d) -> d.env

    if scalesTrain is 'fixed'
      _.each envs, (env) ->
        scaleSet = env.get 'scales'
        scaleSet.merge masterScaleSet, no
    else
      xs = gg.core.FormUtil.pick datas, 'x'
      ys = gg.core.FormUtil.pick datas, 'y'
      @trainFreeScales envs, xs, ys


  @trainFreeScales: (envs, xs, ys) ->
    xKey = gg.facet.base.Facets.facetXKey
    yKey = gg.facet.base.Facets.facetYKey

    xScaleSets = _.map xs, (x) ->
      xenvs = _.filter envs, (env) -> env.get(xKey) is x
      gg.scale.Set.merge(_.map xenvs, (e) -> e.get 'scales')
        .exclude(gg.scale.Scale.ys)

    yScaleSets = _.map ys, (y) ->
      yenvs = _.filter envs, (env) -> env.get(yKey) is y
      gg.scale.Set.merge(_.map yenvs, (e) -> e.get 'scales')
        .exclude(gg.scale.Scale.xs)

    # Expand Domains (not implemented)

    # Merge into each layer's scale sets
    _.each envs, (env) ->
      x = env.get xKey
      y = env.get yKey
      xidx = _.indexOf xs, x
      yidx = _.indexOf ys, y
      scaleSet = env.get('scales')
      scaleSet.merge xScaleSets[xidx], no
      scaleSet.merge yScaleSets[yidx], no


  expandDomains: (scalesSet) ->
    return scalesSet

    _.each scalesSet.scalesList(), (scale) =>
      return unless scale.type is gg.data.Schema.numeric

      [mind, maxd] = scale.domain()
      extra = if mind == maxd then 1 else Math.abs(maxd-mind) * 0.05
      mind = mind - extra
      maxd = maxd + extra
      scale.domain [mind, maxd]

    # XXX: this should be done in the scales/scalesSet object!!!


