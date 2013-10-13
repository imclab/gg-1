#<< gg/facet/pane/container
#<< gg/facet/base/layout


class gg.facet.grid.Layout extends gg.facet.base.Layout
  @ggpackage = "gg.facet.grid.Layout"

  #
  # compute layout information for each pane in the grid view
  #
  layoutPanes: (tset, params, lc) ->
    xFacet = 'facet-x'
    yFacet = 'facet-y'
    md = tset.getMD()
    partitions = tset.partition [xFacet, yFacet]

    # Setup Variables
    log = @log
    container = lc.plotC
    [w,h] = [container.w(), container.h()]
    paddingPane = params.get 'paddingPane'
    showXAxis = params.get 'showXAxis'
    showYAxis = params.get 'showYAxis'

    xs = _.uniq md.getColumn(xFacet)
    ys = _.uniq md.getColumn(yFacet)
    nxs = xs.length
    nys = ys.length

    # Compute derived values
    css = { 'font-size': '10pt' }
    dims = _.textSize @getMaxYText(tset), css
    yAxisW = dims.w + paddingPane
    labelHeight = _.exSize().h + paddingPane
    showXFacet = xs.length > 1 and xs[0]?
    showYFacet = ys.length > 1 and ys[0]?

    log "paddingPane, envs, xs, ys:"
    log paddingPane
    log envs
    log xs
    log ys
    for x, xidx in xs
      for y, yidx in ys
        ts = gg.core.FormUtil.facetTables datas, x, y
        log ts
        log "facet #{x} #{y} has #{_.map ts,
          (t)->t.nrows()} rows"
    log "yAxisW: #{yAxisW}"


    # Initialize PaneContainers for each facet pane
    grid = _.map xs, (x, xidx) ->
      _.map ys, (y, yidx) ->
        bXFacet = showXFacet and yidx is 0
        bYFacet = showYFacet and xidx >= nxs-1
        bXAxis = showXAxis and yidx >= nys-1
        bYAxis = showYAxis and xidx is 0
        log "pane(#{xidx},#{yidx}): x/yfacet: #{bXFacet}, #{bYFacet}\tx/yaxis: #{bXAxis}, #{bYAxis}"
        new gg.facet.pane.Container(
          gg.core.Bound.empty(),
          xidx,
          yidx,
          x,
          y,
          bXFacet,
          bYFacet,
          bXAxis,
          bYAxis,
          labelHeight,
          yAxisW
        )

    # compute actual pane sizes
    # constraints:
    # 1) label and axis heights are fixed (labelHeight)
    # 2) panes all have same height and width
    # 3) total height/width of panes + paddings + label + axes
    #    is equal to container.w()/h()

    # compute available w/h space for panes
    nonPaneWs = _.times nys, ()->0
    nonPaneHs = _.times nxs, ()->0
    _.each grid, (paneCol, xidx) ->
      _.each paneCol, (pane, yidx) ->
        dx = labelHeight*pane.bYFacet+yAxisW*pane.bYAxis
        dy = labelHeight*(pane.bXFacet+pane.bXAxis)
        nonPaneWs[yidx] += dx
        nonPaneHs[xidx] += dy

    # facet, axis width and height
    nonPaneW = _.mmax nonPaneWs
    nonPaneH = _.mmax nonPaneHs
    # total amount of width/height for panes
    paneH = (h - nonPaneH) / nys
    paneW = (w - nonPaneW) / nxs

    # create bounds objects for each pane
    log "creating bounds objects for each pane"
    _.each grid, (paneCol, xidx) ->
      _.each paneCol, (pane, yidx) ->
        pane.c.x1 = paneW
        pane.c.y1 = paneH
        dx = _.sum _.times xidx, (pxidx) -> grid[pxidx][yidx].w()
        dy = _.sum _.times yidx, (pyidx) -> grid[xidx][pyidx].h()
        pane.c.d dx, dy
        pane.c.d pane.yAxisC().w(), pane.xFacetC().h()

        log "pane(#{xs[xidx]},#{ys[yidx]}): #{pane.c.toString()}"



    # 1. add each pane's bounds to their environment
    # 2. update scale sets to be within drawing container
    map = {}
    for x, xidx in xs
      for y, yidx in ys
        paneC = grid[xidx][yidx]
        map[[x,y]] = paneC

        fdatas = gg.core.FormUtil.facetDatas datas, x, y
        for fdata in fdatas
          env = fdata.env
          env.put 'paneC', paneC

          # add in padding to compute actual ranges
          drawC = paneC.drawC()
          xrange = [paddingPane, drawC.w()-2*paddingPane]
          yrange = [paddingPane, drawC.h()-2*paddingPane]

          # update the scales
          scaleSet = gg.core.FormUtil.scales fdata
          for aes in gg.scale.Scale.xs
            for type in scaleSet.types(aes)
              scaleSet.scale(aes, type).range xrange

          for aes in gg.scale.Scale.ys
            for type in scaleSet.types(aes)
              scaleSet.scale(aes, type).range yrange

    set = _.first gg.core.FormUtil.scalesList datas
    @log "grid layout scale set"
    @log set.toString()


    #
    # Compute font sizes and add to envs
    #
    fit = (args...) -> gg.util.Textsize.fit args...
    xfonts = []
    yfonts = []

    for x, xidx in xs
      text = String x
      paneC = grid[xidx][0]
      xfc = paneC.xFacetC()
      optfont = fit text, xfc.w(), xfc.h(), 8, {padding: 2}
      xfonts.push optfont
      @log "optfont x #{text}: #{JSON.stringify optfont}"

    for y, yidx in ys
      text = String y
      paneC = grid[nxs-1][yidx]
      yfc = paneC.yFacetC()
      optfont = fit text, yfc.h(), yfc.w(), 8, {padding: 2}
      yfonts.push optfont
      @log "optfont y #{text}: #{JSON.stringify optfont}"

    minsize = _.min(xfonts, (f) -> f.size).size
    _.each xfonts, (f) -> f.size = minsize
    minsize = _.min(yfonts, (f) -> f.size).size
    _.each yfonts, (f) -> f.size = minsize

    for x, xidx in xs
      for y, yidx in ys
        xfont = xfonts[xidx]
        yfont = yfonts[yidx]

        fenvs = gg.core.FormUtil.facetEnvs datas, x, y
        @log "fenvs for #{x} - #{y}"
        for env in fenvs
          env.put "xfacet-text", xfont.text
          env.put "xfacet-size", xfont.size
          env.put "yfacet-text", yfont.text
          env.put "yfacet-size", yfont.size






