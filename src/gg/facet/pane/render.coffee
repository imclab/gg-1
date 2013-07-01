#<< gg/core/xform

class gg.facet.pane.Svg extends gg.core.XForm
  @ggpackage = "gg.facet.pane.Svg"

  parseSpec: ->
    super
    @params.put "location", "client"

  # Create SVG elements for all facets, axes, and panes
  # Does not render the geometries, simply allocates them
  compute: (table, env, params) ->
    svg = env.get('svg').plot
    b2translate = (b) -> "translate(#{b.x0},#{b.y0})"
    paneC = env.get 'paneC'
    return table unless paneC?

    info = @paneInfo table, env, params
    layerIdx = info.layer
    scaleSet = @scales table, env, params
    dc = paneC.drawC()
    xfc = paneC.xFacetC()
    yfc = paneC.yFacetC()
    xac = paneC.xAxisC()
    yac = paneC.yAxisC()

    @log paneC.toString()
    @log paneC.bound().toString()
    @log paneC.drawC().toString()
    @log paneC.xAxisC().toString()

    el = _.subSvg svg, {
      class: "pane-container layer-#{layerIdx}"
      'z-index': "#{layerIdx+1}"
      transform: b2translate(paneC.bound())
      container: paneC.bound().toString()
    }


    if layerIdx is 0
      _.subSvg el, {
        width: dc.w()
        height: dc.h()
        transform: b2translate dc
        'z-index': 0
        class: 'pane-background facet-grid-background'
      }, 'rect'


    # Top Facet
    if paneC.bXFacet and layerIdx is 0
      xfel = el.append('g').classed('facet-label x', yes)
        .attr('transform', b2translate(xfc))
      xfel.append('rect')
        .attr('width', xfc.w())
        .attr('height', xfc.h())
      xfel.append('text')
        .attr('x', xfc.w()/2)
        .attr('y', xfc.h())
        .attr('dy', '-.5em')
        .text(String(info.facetX))

    # Right Facet
    if paneC.bYFacet and layerIdx is 0
      yfel = el.append('g').classed('facet-label y', yes)
        .attr('transform', b2translate(yfc))
      yfel.append('rect')
        .attr('width', yfc.w())
        .attr('height', yfc.h())
      yfel.append('text')
        .attr('dx', '.5em')
        .attr('y', yfc.h()/2)
        .attr('rotate', 90)
        .text(info.facetY)

    # XXX: also check if we want to show tick lines but not the labels
    # X Axis
    if paneC.bXAxis and layerIdx is 0
      xac2 = xac.clone()
      xael = _.subSvg el, {
        class: 'axis x'
        transform: b2translate xac2
      }

      xscale = scaleSet.scale 'x', gg.data.Schema.unknown
      axis = d3.svg.axis().scale(xscale.d3()).orient('bottom')
      if xscale.type is gg.data.Schema.numeric
        tickSize = dc.h()
        axis.ticks(5).tickSize(-tickSize)
        #axis.tickFormat('') unless paneC.yidx is nys-1

      xael.call axis

    # Y Axis
    if paneC.bYAxis and layerIdx is 0
      yac2 = yac.clone()
      yac2.d yac.w(), 0
      yael = _.subSvg el, {
        class: 'axis y'
        transform: b2translate yac2
      }

      yscale = scaleSet.scale 'y', gg.data.Schema.unknown
      axis = d3.svg.axis().scale(yscale.d3()).orient('left')
      if yscale.type is gg.data.Schema.numeric
        tickSize = dc.w()
        axis.ticks(5, d3.format(',.0f'), 5)
            .tickSize(-tickSize)
        #axis.tickFormat('') unless paneC.xidx is 0

      yael.call axis


    paneSvg = _.subSvg el, {
      class: 'layer-pane facet-grid'
      transform: b2translate(dc)
      width: dc.w()
      height: dc.h()
      id: "facet-grid-#{paneC.xidx}-#{paneC.yidx}-#{layerIdx}"
    }
    env.get('svg').pane = paneSvg


    table




