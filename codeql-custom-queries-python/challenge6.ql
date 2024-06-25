/**
 * @id codeql-zero-to-hero/6
 * @kind path-problem
 * @desc Global taint flow query
 * @severity error
 */

import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.RemoteFlowSources
import MyFlow::PathGraph

class ExecuteCall extends DataFlow::CallCfgNode {
  ExecuteCall() {
    this =
      API::moduleImport("django")
          .getMember("db")
          .getMember("connection")
          .getMember("cursor")
          .getReturn()
          .getMember("execute")
          .getACall()
  }
}

private module MyConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source = API::moduleImport("flask").getMember("request").asSource()
  }

  predicate isSink(DataFlow::Node sink) { exists(ExecuteCall call | sink = call.getArg(0)) }
}

module MyFlow = TaintTracking::Global<MyConfig>;

from MyFlow::PathNode source, MyFlow::PathNode sink
where MyFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "execute sink called with untrusted data $@", sink, "user input"
