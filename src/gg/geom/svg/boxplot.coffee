#<< gg/geom/render

class gg.geom.svg.Boxplot extends gg.geom.Render
  @ggpackage = "gg.geom.svg.Boxplot"
  @aliases: ["schema", "boxplot"]


  defaults: ->
    "stroke-width": 1
    stroke: "steelblue"
    fill: d3.rgb("steelblue").brighter(2)
    "fill-opacity": 0.5

  inputSchema: ->
    ['x','q1', 'median', 'q3', 'lower', 'upper',
      'outlier', 'min', 'max']

  render: (table, svg) ->
    nonoutliers = table.schema.exclude 'outlier'
    boxtables = table.partition(nonoutliers.cols, 'table').all('table')

    # attributes should be imported in bulk using
    # .attr( {} ) where {} is @attrs
    boxes = svg.append("g").classed('boxes geoms', true)
    boxes = boxes.selectAll('g')
      .data(boxtables)
    enter = boxes.enter()
      .append("g")
      .attr("class", "boxplot")

    y = (t) -> Math.min(t.any('y0'), t.any('y1'))
    height = (t) -> Math.abs(t.any('y1') - t.any('y0'))
    width = (t) -> t.any('x1') - t.any('x0')
    #width = (t) -> t.get('width')
    x0 = (t) -> t.any 'x0'
    x1 = (t) -> t.any 'x1'
    #x0 = (t) -> t.get('x') - t.get('width') / 2.0
    #x1 = (t) -> t.get('x') + t.get('width') / 2.0




    # iqr
    iqr = @applyAttrs enter.append('rect'),
      class: "boxplot iqr"
      x: x0
      y: (t) -> Math.min(t.any('q3'), t.any('q1'))
      width: width
      height: (t) -> Math.abs(t.any('q1') - t.any('q3'))

    median = @applyAttrs enter.append('line'),
      class: "boxplot median"
      x1: x0
      x2: x1
      y1: (t) -> t.any 'median'
      y2: (t) -> t.any 'median'

    # upper whisker
    upperw = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.any 'x'
      x2: (t) -> t.any 'x'
      y1: (t) -> t.any 'q3'
      y2: (t) -> t.any 'upper'

    # upper tick
    uppert = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.any('x')-width(t)*0.2
      x2: (t) -> t.any('x')+width(t)*0.2
      y1: (t) -> t.any 'upper'
      y2: (t) -> t.any 'upper'


    # lower whisker
    lowerw = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.any 'x'
      x2: (t) -> t.any 'x'
      y1: (t) -> t.any 'q1'
      y2: (t) -> t.any 'lower'


    # lower tick
    lowert = @applyAttrs enter.append("line"),
      class: "boxplot whisker"
      x1: (t) -> t.any('x')-width(t)*0.2
      x2: (t) -> t.any('x')+width(t)*0.2
      y1: (t) -> t.any 'lower'
      y2: (t) -> t.any 'lower'

    circles = enter.selectAll("circle")
      .data((d) -> 
        d.all().filter (row) -> 
          _.isValid(row.get('outlier')))
    enterCircles = circles.enter().append("circle")

    @applyAttrs enterCircles,
      class: "boxplot outlier"
      cx: (t) -> t.get 'x'
      cy: (t) -> t.get 'outlier'


    gs = [enter]# [iqr, median, upperw, uppert, lowerw, lowert]
    _.each gs, (g) =>
      cssOver =
        "fill-opacity": 1
        "stroke-opacity": 1
        fill: (t) -> d3.rgb(t.any('fill')).darker(1)
        stroke: (t) -> d3.rgb(t.any "stroke").darker(2)
        "stroke-width": (t) -> t.any("stroke-width") + 0.5

      cssOut =
        "fill-opacity": (t) -> t.any('fill-opacity')
        "stroke-opacity": (t) -> t.any("stroke-opacity")
        fill: (t) -> t.any('fill')
        stroke: (t) -> t.any "stroke"
        "stroke-width": (t) -> t.any "stroke-width"

      @applyAttrs g, cssOut
      _this = @
      g
        .on("mouseover", (d, idx) -> _this.applyAttrs d3.select(@), cssOver)
        .on("mouseout", (d, idx) -> _this.applyAttrs d3.select(@), cssOut)



