Desired Features
----------

1. SQL source operator.  Server only
1. Compile a server-side source + map/group operator into a SQL statement
1. Implement a generalized Group-by aggregate operator
1. Schema based provenance.  Use to do between-operator schema mapping
1. Data provenance to map from dom element to data and back
1. Better JS interface
  * ggplot2-like interface
1. Node-failure tolerance.  If a node throws an exception, dont block workflow on the next barrier, keep going.

July 1, 2013
----------------

Added hooks in logger so that debugging levels can be specified through the `debug` components of gg spec.  Each key/val pair specifies a class path prefix and the debugging level:
    
    {
        debug: {
            "gg":        gg.util.Log.ERROR   // by default, only show errors
            "gg.wf":     gg.util.Log.DEBUG   // show all log msgs in gg.wf package
            "gg.wf.rpc": gg.util.log.ERROR   // but only errors in rpc package
        }
    }      

Added node->[list of nodes] optimizer rule.

Switched node location from "clientonly" flag to "location = client/server" key/val pair.

June 27, 2013
----------------

Sucessfully switched to simpler model.  Currently

1. On execution, client serializes and registers workflow with server
2. Nodes block until full result set is competed -- no incremental computing
3. Nodes are labeled with the location they should execute (client/server)
4. Workflows are executed via message passing, and edges that cross client/server
   boundaries are serialized and passed.
5. Workflow runner uses a clearing house that figures out what node to pass a dataset off to next.
   Runner has access to a read-only workflow instance.

Next step -- operator to SQL mapping

1. <strike>set server-side only operator</strike>
1. <strike>node->node rule</strike>

Misc

1. Reorganize package hierarchy.
1. util/ is really messy


June 20, 2013
------------------

Talked to Sam, the execution model is too complicated.  Switching to model where

1. each operator consumes and produces a nested array of gg.wf.Data objects
  * run(nestedArray, params) -> nestedArray
    * emits its results
    * returns its results too
  * ready() -> bool
  * Single child nodes
    * exec calls compute on the leaves (each gg.wf.Data object)
    * split transforms each leaf into an array of gg.wf.Data objects
    * join merges the leaf arrays
  * Multi-child nodes
    * barrier takes multiple arrays as input, and sends each array out to the corresponding child nodes
    * multicast "clones" its inputs and sends the clones to the corresponding child nodes
2. no parallelization except within an operator.
   This means each operator is blocking until its complete
3. workflow tracks
  * number of input slots and children for each operator
  * consumes operator output and places them in child slots
  * calls operator.ready()
  * doesnt need to instantiate


June 17, 2013
-------------------

Implemented simple RPC-based barrier and exec using socket.io.  Can run the facet layout algorithm.

Changed the workflow runner to use callback based execution (for rpc nodes).

Need a way to pass static functions (inputSchema, outputSchema, validate) to the server.  In general,
@params may include static functions.  Need an automatic way to identify them.

  * inputSchema
  * defaults
  * outputSchema
  * provenanceCode



June 10, 2013
-------------
* DONE separate facet/graphic layout from rendering
  * layout just computes bounds for containers, render actually creates and styles elements

* DONE Separate specification based data (@params) from values
  derived from data (e.g., yAxisText)
  * @params is stored in the object
  * env stores values derived from data

Serializing a wf Operator

* Methods can be referenced using a function object, or the containing class
  * klass name + params object fully describe a single transform
  * add parent/child/port relationships to serialize a workflow node
* XForm operators can be re-instantiated
  * inputSchema
  * outputSchema
  * provenance stuff
  * defaults
  * compute
  * klassname
* wf nodes simply call compute
* Workflow state
  * children, parents, port relationships

* Create Specs for workflow
* Be able to mark operators as client/server
* Support passing functions or function references to the server
* Differentiate XForm/BForm rpc operators from wf operators
* DONE: Run facet layout algorithm on the server and pass control back
  * Either serialize compute function, or add a pointer to
    retrieve function on the server side
  * Latter needs to unique ID every function


* Validation requires
  * data schema validation
  * environment validation
  * parameter validation


### Distinguishing State

Compute operators

1. only depends on env, data, params
2. params dont change
3. use param.get() to access parameters
4. use env.get()/put() to access runtime values
5. use table to access data
6. certain env variables are guaranteed to exist for certain operator types
   (stat operators have access to scales)
7. everything needs to be JSONable -- has toJSON() and fromJSON()

Workflow operators

1. class properties are all workflow management related
   only "node.params" can be used in the computation
2. compute signature is f(table, env, params)

Params

* Processed spec valuess
* Options
* Distinguish functions that should be called and fuctions that are interpreted as blobs

Env

* Svg elements
* Containers
* Facet values
* Label text

Main SVG dom elements:

    baseSvg
      facetsSvg
        plotSvg
          paneSvg





June 07, 2013
--------------

Lost all the previous notes thanks to stupidity with git.

Switching all operators to be pure functions that only depend on three data
structures that are passed into the operators

1. User defined parameter values.  Assigned at compile time
2. Table(s)
3. Environment values (derived from computation)

This decision was because splitting execution between the browser and backend
is too complex otherwise.



