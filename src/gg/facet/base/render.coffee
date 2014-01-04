

class gg.facet.base.Render extends gg.core.BForm
  @ggpackage = "gg.facet.base.Render"


  parseSpec: ->
    super

    @params.ensureAll
      'svg': [[], @spec.svg]
      'fXLabel': [[], 'x facet']
      'fYLabel': [[], 'y facet']
    @params.put "location", "client"


  renderLabels: (md, params, lc) ->
    options = params.get 'options'
    fXLabel = params.get 'fXLabel'
    fYLabel = params.get 'fYLabel'
    svg = md.any('svg').facets
    bgC = lc.background
    xflC = lc.xFacetLabelC
    yflC = lc.yFacetLabelC
    xalC = lc.xAxisLabelC
    yalC = lc.yAxisLabelC
    plotC = lc.plotC
    b2translate = (b) -> "transform(#{b.x0},#{b.y0})"

    @log "yalC #{yalC.toString()}" if yalC?
    @log "xalC #{xalC.toString()}" if xalC?

    _.subSvg svg, {
      class: 'plot-background'
      width: bgC.w()
      height: bgC.h()
    }, 'rect'


    wRatio = plotC.w() / bgC.w()
    hRatio = plotC.h() / bgC.h()
    transform = "#{b2translate plotC}scale(#{wRatio},#{hRatio})"
    matrix = "#{wRatio},0,0,#{hRatio},#{plotC.x0},#{plotC.y0}"
    plotSvg = _.subSvg svg, {
      transform: "matrix(#{matrix})"
      class: 'graphic-with-margin'
      container: plotC.toString()
    }



    # X Facet
    if xflC? and xflC.v()
      _.subSvg(svg, {
        transform: "translate(#{xflC.x0}, #{xflC.y0})"
        class: 'facet-title x-facet-title'
      }).append('text')
        .text(fXLabel)
        .attr("dy", "1em")
        .attr('text-anchor', 'middle')

    # Y Facet
    if yflC? and yflC.v()
      c = _.subSvg svg, {
        transform: "translate(#{yflC.x0}, #{yflC.y0})"
        class: 'facet-title y-facet-title'
        container: yflC.toString()
      }
      _.subSvg(c, {
        "text-anchor": "middle"
        transform: "rotate(90)"
        y: 0
        dy: ".5em"
      }, 'text').text(fYLabel)

    # X Axis
    if xalC? and xalC.v()
      _.subSvg(svg, {
        transform: "translate(#{xalC.x0},#{xalC.y0})"
        class: "x-axis-container"
      }).append('text')
        .text(options.xaxis)
        .attr('text-anchor', 'middle')
        .attr("dy", "-1em")

    if yalC? and yalC.v()
      yalSvg = _.subSvg(svg, {
        transform: "translate(#{yalC.x0},#{yalC.y0})"
        class: "y-axis-container"
        container: yalC.toString()
      })

      _.subSvg(yalSvg, {
        transform: "rotate(-90)"
        'text-anchor': 'middle'
        y: 0
        dy: "1em"
      }, 'text').text(options.yaxis)


    for svg in md.all('svg')
      svg.plot = plotSvg
    
    md

  compute: (pairtable, params) ->
    md = pairtable.right()
    lc = md.any 'lc'
    md = @renderLabels md, params, lc
    pairtable.right md
    pairtable

  @fromSpec: (spec) ->
    new gg.facet.grid.Render spec

