/**
 * @kind path-problem
 */

import go
import codeql.dataflow.DataFlow
import semmle.go.security.FlowSources
import semmle.go.dataflow.internal.DataFlowNodes

class CreateModel extends Function {
  CreateModel() {
    this.getName() = "CreateModel" and
    this.getNumParameter() = 6 and
    this.getPackage().getName() = "server"
  }
}

class ParseFile extends Function {
  ParseFile() { this.getName() = "ParseFile" }
}

class GetBlobsPath extends Function {
  GetBlobsPath() { this.getName() = "GetBlobsPath" }
}

class Open extends Function {
  Open() {
    this.hasQualifiedName("os", "Open")
  }
}

module ZipSlipConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source instanceof RemoteFlowSource and
    source.getEnclosingCallable().asFunction().getName() = "CreateModelHandler"
  }

  predicate isSink(DataFlow::Node sink) {
    exists(CreateModel cf | cf.getParameter(4) = sink.asParameter())
  }

  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(Callable call, Public::CallNode mc |
      call.asFunction() instanceof ParseFile and
      call.asFunction().getParameter(0) = node1.asParameter() and
      node2.asExpr() = call.asFunction().getACall().asExpr()
      or
      call.asFunction() instanceof GetBlobsPath and
      call.asFunction().getParameter(0) = node1.asParameter() and
      node2.asExpr() = call.asFunction().getACall().asExpr()
      or
      mc.getTarget().getName() = "Open" and
      mc.getTarget().getParameter(0) = node1.asParameter() and
      mc.getReceiver() = node2
    )
  }
}

module ZipSlipFlow = TaintTracking::Global<ZipSlipConfig>;

import ZipSlipFlow::PathGraph

int explorationLimit() { result = 3 }

module MyPartialFlow = ZipSlipFlow::FlowExplorationFwd<explorationLimit/0>;

predicate adhocPartialFlow(
  Callable c, MyPartialFlow::PartialPathNode n, DataFlow::Node src, int dist
) {
  exists(MyPartialFlow::PartialPathNode source |
    MyPartialFlow::partialFlow(source, n, dist) and
    src = source.getNode() and
    c = n.getNode().getEnclosingCallable() and
    c.asFunction().getName() = "CreateModel"
  )
}

from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
where ZipSlipFlow::flowPath(source, sink)
select sink, source, sink, "Zip slip $@", sink, "unstrusted input"
