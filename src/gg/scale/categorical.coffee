#<< gg/scale/scale

class gg.scale.BaseCategorical extends gg.scale.Scale
  @ggpackage = 'gg.scale.BaseCategorical'

  # subclasses are responsible for instantiating @d3Scale and @invertScale
  constructor: (@spec) ->
    @type = data.Schema.ordinal
    @d3Scale = d3.scale.ordinal()
    @invertScale = d3.scale.ordinal()
    @isInterval = no
    super

  @defaultDomain: (col) ->
      vals = _.uniq _.flatten(col)
      # XXX: this is not useful and prevents data sorting
      #vals.sort (a,b)->a-b
      vals

  clone: ->
    ret = super
    ret.d3Scale = @d3Scale.copy()
    ret.isInterval = @isInterval
    ret.invertScale = @invertScale.copy()
    ret

  defaultDomain: (col) -> gg.scale.BaseCategorical.defaultDomain col

  mergeDomain: (domain) ->
    domain ?= []
    newDomain = _.uniq domain.concat(@domain())
    #newDomain = newDomain.sort()
    @domain newDomain

  domain: (interval) ->
    if interval?
      @invertScale.range interval
    super

  d3Range: ->
    range = @d3Scale.range()
    if @type == data.Schema.numeric
      rangeBand = @d3Scale.rangeBand()
      range = _.map range, (v) -> v + rangeBand/2.0
    range

  range: (interval) ->
    if interval? and interval.length > 0 and not @rangeSet

      #XXX: rangeBand vs range changes depending on if we're rendering
      #     points or rectangles?
      if _.isString interval[0]
        @isInterval = no
        @d3Scale.range interval
      else if data.Schema.type(interval[0]) == data.Schema.numeric
        @isInterval = yes
        @d3Scale.rangeBands interval#, @padding
      else
        @isInterval = yes
        @d3Scale.rangePoints interval
        @d3Scale.rangeBands interval
      @invertScale.domain @d3Range()
    @d3Range()

  resetDomain: ->
    @domainUpdated = false
    @domain [] unless @domainSet
    @invertScale.domain [] unless @domainSet

  invert: (v) -> @invertScale v

  #scale: (v) -> @d3Scale(v) + @d3Scale.rangeBand()/2 

  valid: (v) -> v in @domain()



