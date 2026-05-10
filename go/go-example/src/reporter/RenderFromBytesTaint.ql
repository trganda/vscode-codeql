/**
 * @id trganda/go-example/renderfrombytes-taint
 * @name Untrusted input flowing to RenderFromBytes templateBytes
 * @description Tracks taint from remote sources to the templateBytes argument of (*TemplateRenderer).RenderFromBytes.
 * @kind path-problem
 * @precision medium
 * @problem.severity warning
 * @tags go-example security
 */

import go
import semmle.go.dataflow.TaintTracking
import semmle.go.security.FlowSources

module TemplateBytesConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  predicate isSink(DataFlow::Node sink) {
    exists(Method m, DataFlow::CallNode call |
      m.hasQualifiedName(_, "TemplateRenderer", "RenderFromBytes") and
      sink.asParameter() = m.getParameter(1)
    )
  }
}

module TemplateBytesFlow = TaintTracking::Global<TemplateBytesConfig>;

import TemplateBytesFlow::PathGraph

from TemplateBytesFlow::PathNode source, TemplateBytesFlow::PathNode sink
where TemplateBytesFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Remote source $@ flows to templateBytes in RenderFromBytes.", source.getNode(), "here"
