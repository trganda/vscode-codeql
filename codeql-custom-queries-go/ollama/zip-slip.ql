/**
 * @name Zip Slip of Ollama
 * @kind path-problem
 * @problem.severity warning
 * @id go/example/empty-block
 */

import go
import codeql.dataflow.DataFlow
import semmle.go.security.ZipSlip
import semmle.go.security.FlowSources

class ParseFromZipFile extends Function {
  ParseFromZipFile() { this.getName() = "parseFromZipFile" }
}

class ParseFile extends Function {
  ParseFile() { this.getName() = "ParseFile" }
}

class GetBlobsPath extends Function {
  GetBlobsPath() { this.getName() = "GetBlobsPath" }
}

module ZipSlipConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source instanceof RemoteFlowSource and
    source.getEnclosingCallable().asFunction().getName() = "CreateModelHandler"
  }

  predicate isSink(DataFlow::Node sink) {
    exists(ParseFromZipFile zs | zs.getParameter(1) = sink.asParameter())
  }

  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(Callable call, Callable call2 |
      call.asFunction() instanceof ParseFile and
      call.asFunction().getParameter(0) = node1.asParameter() and
      node2.asExpr() = call.asFunction().getACall().asExpr()
      or
      call2.asFunction() instanceof GetBlobsPath and
      call2.asFunction().getParameter(0) = node1.asParameter() and
      node2.asExpr() = call2.asFunction().getACall().asExpr()
    )
  }
}

module ZipSlipFlow = TaintTracking::Global<ZipSlipConfig>;

import ZipSlipFlow::PathGraph

from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
where ZipSlipFlow::flowPath(source, sink)
select sink, source, sink, "Zip slip $@", sink, "unstrusted input"
