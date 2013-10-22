#<< gg/core/bform

class gg.core.Render extends gg.core.BForm
  @ggpackage = "gg.core.Render"

  parseSpec: ->
    super
    @params.put "location", 'client'

  compute: (pairtable, params) ->
    md = pairtable.getMD()
    row = md.get 0
    svg = row.get('svg').base
    lc = row.get 'lc'
    throw Error() unless lc?

    c = lc.baseC
    options = params.get 'options'


    svg
      .attr('width', c.w())
      .attr('height', c.h())


    _.subSvg svg, {
      class: 'graphic-background'
      width: '100%'
      height: '100%'
    }, 'rect'

    titleC = lc.titleC
    if titleC
      text = _.subSvg svg, {
        'text-anchor': 'middle'
        class: 'graphic-title'
        dx: titleC.x0
        dy: '1em'
      }, 'text'
      text.text options.title

    facetC = lc.facetC
    facetsSvg = _.subSvg svg, {
      transform: "translate(#{facetC.x0},#{facetC.y0})"
      width: facetC.w()
      height: facetC.h()
    }

    # TODO: render guides
    guideC = lc.guideC


    # update md variables
    for svg in md.getColumn 'svg'
      svg.facets = facetsSvg
    new gg.data.PairTable pairtable.getTable(), md
