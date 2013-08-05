#<< gg/util/*

#
# Processing:
# 1) Splits dataset to be processed for different facets
#
# Rendering
# 1) Allocates svg elements for each facet pane and
# 2) Provides API to access them
#
# XXX: in the future, this should be an abstract class that computes
#      offset and sizes of containers, and subclasses should use them
#      to create appropriate SVG/Canvas elements
#
#
# Spec:
#
#   facets: {
#     (x|y): ???
#     type: grid|wrap,
#     scales: free|fixed,
#     (size|sizing): free|fixed
#     padding
#     class
#   }
#
#   opts {
#     showXAxis
#     showYAxis
#
#   }
#
class gg.facet.base.Facets
  @ggpackage = "gg.facet.base.Facets"
  @facetXKey = "facet-x"
  @facetYKey = "facet-y"
  @facetXYKeys = "facet-xy"

  constructor: (@g, @spec={}) ->
    @log = gg.util.Log.logger @ggpackage, "Facets"

    @parseSpec()

    @splitter = @splitterNodes()
    @trainer = new gg.scale.train.Master(
      name: 'facet_train').compile()


    # These should be replaced with _actual_ implementations
    layoutParams = @layoutParams.clone()
    layoutParams.put 'klassname', 'gg.facet.grid.Layout'
    @layout1 = new gg.facet.base.Layout(
      name: 'facet-layout1'
      params: @layoutParams).compile()
    @layout2 = new gg.facet.base.Layout(
      name: 'facet-layout2'
      params: @layoutParams).compile()
    @render = new gg.facet.base.Render(
      name: 'facet-render'
      params: @renderParams).compile()


  parseSpec: ->
    @splitParams = new gg.util.Params {
      x: _.findGood [@spec.x, null]
      y: _.findGood [@spec.y, null]
      scales: _.findGood [@spec.scales, "fixed"]
      type: _.findGood [@spec.type, "grid"]
      sizing: _.findGood [@spec.sizing, @spec.size, "fixed"]
      options: @g.options
    }

    xattrs = ['showx', 'showX', 'showXAxis']
    yattrs = ['showy', 'showY', 'showYAxis']
    ncol = ["ncols", "ncol", "nys", "ny"]
    nrow = ["nrows", "nrow", "nxs", "nx"]
    @layoutParams = new gg.util.Params {
      showXAxis: _.findGoodAttr @spec, xattrs, yes
      showYAxis: _.findGoodAttr @spec, yattrs, yes
      ncol: _.findGoodAttr @spec, ncol, null
      nrow: _.findGoodAttr @spec, nrow, null
      paddingPane: @spec.padding or @spec.paddingPane or 5
      margin: @spec.margin or 1
      options: @g.options
    }

    fClass = _.findGoodAttr @spec, ['facetclass', 'class'], ''
    @renderParams = new gg.util.Params {
      fXLabel: _.findGoodAttr @spec, ['xlabel', 'xLabel'], "x facets"
      fYLabel: _.findGoodAttr @spec, ['ylabel', 'yLabel'], "y facets"
      fClass: fClass
      exSize: _.exSize {class: fClass}
      showXTicks: _.findGood [@spec.showXTicks, true]
      showYTicks: _.findGood [@spec.showYTicks, true]
      options: @g.options
      location: "client"
    }





  # Return workflow nodes that split the dataset along the
  # x and y facets
  splitterNodes: ->
    # XXX: This implementation is not exactly right, because
    # it will not result in groups for x/y facetpairs that
    # don't have any tuples.  this should only be apparent
    # when using "wrap" (we expect the cross product!)
    facetXKey = gg.facet.base.Facets.facetXKey
    facetYKey = gg.facet.base.Facets.facetYKey
    x = _.flatten [@splitParams.get('x')]
    y = _.flatten [@splitParams.get('y')]
    facetXNode = new gg.wf.PartitionCols
      name: 'facet-x'
      params:
        key: facetXKey
        cols: x
    facetYNode = new gg.wf.PartitionCols
      name: 'facet-y'
      params:
        key: facetYKey
        cols: y
    [facetXNode, facetYNode]

  # This executes on a per-facet-layer basis
  # Not a barrier
  labelerNodes: ->
    throw Error("labeler not implemented")

  @fromSpec: (g, spec) ->
    spec.type = spec.type or "grid"

    klass = if spec.type is "wrap"
      gg.facet.wrap.Facets
    else
      gg.facet.grid.Facets

    new klass g, spec



