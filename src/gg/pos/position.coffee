#<< gg/core/xform

class gg.pos.Position 
  @ggpackage = "gg.pos.Position"

  @klasses: ->
    klasses = [
      gg.pos.Identity
      gg.pos.Shift
      gg.pos.Jitter
      gg.pos.Stack
      gg.pos.Dodge
      gg.pos.Text
      gg.pos.Bin2D
      gg.pos.DotPlot
    ]
    ret = {}
    _.each klasses, (klass) ->
      if _.isArray klass.aliases
        _.each klass.aliases, (alias) -> ret[alias] = klass
      else
        ret[klass.aliases] = klass
    ret

  @fromSpec: (spec) ->
    klasses = gg.pos.Position.klasses()
    if _.isString spec
      type = spec
      spec = {}
    else
      type = _.findGood [spec.type, spec.pos, "identity"]

    klass = klasses[type] or gg.pos.Identity

    @log "fromSpec: #{klass.name}\tspec: #{JSON.stringify spec}"

    ret = new klass spec
    ret

class gg.pos.Identity extends gg.core.XForm
  @ggpackage = "gg.pos.Identity"
  @aliases = ["identity"]

  compute: (pairtable, params) -> pairtable
  @compile: -> []
