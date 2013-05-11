#<< gg/wf/node

#
# A 1-to-1 mapping XForm.  A mapping is defined with a dictionary of
#
#   target-col-name: map-spec
#
# where map-spec is one of:
#
# 1) "attribute"
# 2) object
# 3) function: (tuple) -> object
# 4) ecmascript expression: will use eval() to transform into function
#
# under the covers, the map-specs are compiled into functions.
#
#
class gg.Mapper extends gg.XForm
  constructor: (@g, @spec) ->
    super @g, @spec
    @parseSpec()

    @type = "mapper"
    @name = findGood [@spec.name, "mapper-#{@id}"]

  @fromSpec: (g, spec) ->
    spec = _.clone spec
    attrs = ["mapping", "map", "aes", "aesthetic", "aesthetics"]
    mapping = findGoodAttr spec, attrs, null
    return null unless mapping?

    aesthetics = _.keys mapping

    # aes should be the mapping
    spec.aes = mapping
    inverse = {}
    _.each mapping, (val, key) -> inverse[val] = key

    new gg.Mapper g, spec


  parseSpec: ->
    @mapping = @spec.aes
    @aes = @aesthetics = _.keys @mapping
    @inverse = @spec.inverse or {}
    console.log "mapper spec: #{JSON.stringify @mapping}"

    super

  compute: (table, env, node) ->
    console.log "transform: #{JSON.stringify @mapping}"
    console.log "table:     #{JSON.stringify table.colNames()}"
    table = table.clone()
    functions = _.mappingToFunctions table, @mapping
    table = table.transform functions, yes
    table

  invertColName: (outColName) -> @inverse[outColName]

