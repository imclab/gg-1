require "../env"
vows = require "vows"
assert = require "assert"

makeTable = (nrows=100) ->
  rows = _.map _.range(0, nrows), (d) ->
    g = Math.floor(Math.random() * 2)
    f = Math.floor(Math.random() * 2) * 10
    t = Math.floor(Math.random() * 3)
    {
      d:d
      r:d# 1 + t * 0.5 + Math.abs(Math.random()) + g
      g: g
      f:f
      t:t
    }
  new gg.RowTable rows


outputsProperlyGen = (check) ->

    (node) ->
        node = node.cloneSubplan()[0]
        node.addOutputHandler 0, (id, output) ->
            table = output.table
            table.each check

        t = makeTable(10)
        node.addInput(0, 0, t)
        node.run()



suite = vows.describe "graphic.coffee"

spec =
  layers: [
    {
      geom: {type:"point", aes: {y:"total", r:"total"}},
      aes:
        x: "d"
        y: "r"
        fill: 'f'
        r: "r"
        "fill-opacity": "0.6"
      pos: {type:"jitter", scale: 0.2}
      stat: "bin"

    }
  ]
  facets:
    x: "f"
    y: "g"
  scales:
    x:
      type: "log"
    r:
      type: "linear"
      range: [2, 5]


suite.addBatch
  "basic graphic":
    topic: ()->
      graphic = new gg.Graphic spec
      graphic


    "can run": (graphic) ->
      svg = d3.select("body").append("svg")
      graphic.render 500, 500, svg, makeTable(500)


suite.export module
