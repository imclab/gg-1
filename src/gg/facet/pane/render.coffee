#<< gg/core/xform

class gg.facet.pane.Svg extends gg.core.XForm
  @ggpackage = "gg.facet.pane.Svg"

  parseSpec: ->
    super
    @params.put "location", "client"

  # Create SVG elements for all facets, axes, and panes
  # Does not render the geometries, simply allocates them
  compute: (data, params) ->
    table = data.table
    env = data.env
    svg = env.get('svg').plot
    b2translate = (b) -> "translate(#{b.x0},#{b.y0})"
    paneC = env.get 'paneC'
    return table unless paneC?

    info = @paneInfo data, params
    layerIdx = info.layer
    scaleSet = @scales data, params
    dc = paneC.drawC()
    xfc = paneC.xFacetC()
    yfc = paneC.yFacetC()
    xac = paneC.xAxisC()
    yac = paneC.yAxisC()

    @log "panec: #{paneC.toString()}"
    @log "bound: #{paneC.bound().toString()}"
    @log "drawC: #{paneC.drawC().toString()}"
    @log "xaxis: #{paneC.xAxisC().toString()}"
    @log "yFacet:#{yfc.toString()}" if yfc?
    @log "layer: #{layerIdx}"

    el = _.subSvg svg, {
      class: "pane-container layer-#{layerIdx}"
      'z-index': "#{layerIdx+1}"
      transform: b2translate(paneC.bound())
      container: paneC.bound().toString()
    }

    # Render the background for the first layer
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
      text = env.get "xfacet-text"
      size = env.get "xfacet-size"

      xfel = _.subSvg el,
        class: "facet-label x"
        transform: b2translate xfc

      _.subSvg xfel, {
        width: xfc.w()
        height: xfc.h()
      }, "rect"

      _.subSvg(xfel, {
        x: xfc.w()/2
        y: xfc.h()
        dy: "-.5em"
        "text-anchor": "middle"
      }, "text")
        .text(text)
        .style("font-size", "#{size}pt")

    # Right Facet
    if paneC.bYFacet and layerIdx is 0
      @log env
      text = env.get "yfacet-text"
      size = env.get "yfacet-size"

      yfel = _.subSvg(el, {
        class: "facet-label y"
        transform: b2translate yfc
        container: yfc.toString()
      })

      _.subSvg(yfel, {
        width: yfc.w()
        height: yfc.h()
      }, "rect")

      yftext = _.subSvg(yfel, {
        y: "-.5em"
        x: yfc.h()/2
        "text-anchor": "middle"
        transform: "rotate(90)"
      }, "text")
        .text(text)
        .style("font-size", "#{size}pt")

    # XXX: also check if we want to show tick lines but not the labels
    # X Axis
    if layerIdx is 0
      xac2 = xac.clone()
      xael = _.subSvg el, {
        class: 'axis x'
        transform: b2translate xac2
      }

      xscale = scaleSet.scale 'x', gg.data.Schema.unknown
      axis = d3.svg.axis().scale(xscale.d3()).orient('bottom')
      tickSize = dc.h()
      axis.tickSize -tickSize
      axis.tickFormat('') unless paneC.bXAxis

      # TODO: figure out how many ticks to render
      if xscale.type is gg.data.Schema.numeric or xscale.type is gg.data.Schema.date
        d3scale = xscale.d3()
        nticks = 5
        fmtr = axis.tickFormat() or d3scale.tickFormat() or String
        @log "autotuning x axis ticks"
        @log d3scale.ticks
        @log "tickFormat is function: #{_.isFunction fmtr}"
        if d3scale.ticks? and _.isFunction fmtr
          nticks = 2
          for n in _.range(1, 10)
            ticks = _.map d3scale.ticks(n), fmtr
            ticksizes = _.map ticks, (tick) ->
              gg.util.Textsize.textSize(tick,
                { class: "axis x"},
                xael[0][0]).width
            widthAtTick = _.sum ticksizes
            @log "ticks: #{JSON.stringify ticks}"
            @log "sizes: #{JSON.stringify ticksizes}"
            @log "width: #{widthAtTick}"
            if widthAtTick < dc.w()
              nticks = n
            else
              break

        axis.ticks nticks

      xael.call axis

    # Y Axis
    if layerIdx is 0
      yac2 = yac.clone()
      yac2.d yac.w(), 0
      yael = _.subSvg el, {
        class: 'axis y'
        transform: b2translate yac2
      }

      yscale = scaleSet.scale 'y', gg.data.Schema.unknown
      axis = d3.svg.axis().scale(yscale.d3()).orient('left')
      tickSize = dc.w()
      axis.tickSize -tickSize
      axis.tickFormat('') unless paneC.bYAxis

      @log "yaxis type: #{yscale.type}"
      @log yscale.toString()

      # compute number of ticks to show

      if yscale.type is gg.data.Schema.numeric
        em = _.textSize("m", {padding: 2, class: "axis y"}, yael[0][0])
        nticks = Math.min(5, Math.ceil(dc.h() / em.h))
        axis.ticks(nticks, d3.format(',.0f'), 5)
        @log "yaxis nticks #{nticks}"

      yael.call axis


    # Create and add pane SVG to env
    paneSvg = _.subSvg el, {
      class: 'layer-pane facet-grid'
      transform: b2translate(dc)
      width: dc.w()
      height: dc.h()
      id: "facet-grid-#{paneC.xidx}-#{paneC.yidx}-#{layerIdx}"
    }
    env.get('svg').pane = paneSvg

    data




