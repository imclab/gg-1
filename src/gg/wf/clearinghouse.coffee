
class gg.wf.ClearingHouse extends events.EventEmitter
  @ggpackage = "gg.wf.ClearingHouse"

  constructor: (@runner, @xferControl) ->
    @flow = @runner.flow
    @log = gg.util.Log.logger @constructor.ggpackage, "clearhouse"
    @xferControl = @routeNodeResult.bind(@) unless @xferControl?


  push: (nodeid, outport, outputs) ->
    @runner.setDone nodeid
    node = @flow.nodeFromId nodeid
    @log "push: #{node.name} #{nodeid}(#{outport})"
    if @isSink(nodeid)
      @log "sink node: #{node.name} #{nodeid}"
      @emit "output", nodeid, outport, outputs
    else if @clientToServer nodeid, outport
      @xferControl nodeid, outport, outputs
    else if @serverToClient nodeid, outport
      @xferControl nodeid, outport, outputs
    else
      @routeNodeResult nodeid, outport, outputs


  clientToServer: (nodeid, outport) ->
    node = @flow.nodeFromId nodeid
    @log "clienttoserver: #{[node.name, nodeid, outport, node.location]}"
    return no unless node.location is "client"
    children = @flow.portGraph.children
      n: node
      p: outport

    if children.length is 0
      throw Error("node #{nodeid} with port #{outport} has no children in Port Graph")
    o = children[0]
    child = o.n
    inport = o.p

    @log "clienttoserver: child: #{child.name} #{child.location}"
    child.location is "server"


  serverToClient: (nodeid, outport) ->
    node = @flow.nodeFromId nodeid
    @log "servertoclient: #{[node.name, nodeid, outport, node.location]}"
    return no unless node.location is "server"
    children = @flow.portGraph.children({n: node, p: outport})
    o = children[0]
    child = o.n
    inport = o.p

    @log "servertoclient: #{[node.name, nodeid, outport, node.location]}"
    @log "servertoclient: child: #{child.name} #{child.location}"
    child.location is "client"

  isSink: (nodeid) ->
    nodeid in _.map(@flow.sinks(), (sink) -> sink.id)

  routeNodeResult: (nodeid, outport, input) ->
    node = @flow.nodeFromId nodeid
    children = @flow.portGraph.children
      n: node
      p: outport
    if children.length != 1
      throw Error("children should only be 1")

    o = children[0]
    child = o.n
    inport = o.p

    @log "setInput #{node.name}:#{outport} ->
          #{child.name}:#{inport} #{child.location}"

    child.setInput inport, input

    if child.ready()
      @log "\t#{child.name} adding"
      @runner.tryRun child
    else
      @log "\t#{child.name} not ready
        #{child.nReady()} of #{child.nParents} ready"



