/**
 * @name JXPath Flow Query
 * @kind path-problem
 * @problem.severity warning
 * @id java/inbox/jxpath-flow
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.security.UnsafeDeserializationQuery
import MyFlow::PathGraph

class JXPathContext extends Class {
  JXPathContext() { this.hasQualifiedName("org.apache.commons.jxpath", "JXPathContext") }
}

class JXPathSink extends MethodCall {
  JXPathSink() {
    this.getCallee().getDeclaringType().getASupertype*() instanceof JXPathContext and
    this.getCallee().getName() = "getPointer"
  }
}

class JXPathSinkHandlerInput extends DataFlow::Node {
  JXPathSinkHandlerInput() { exists(JXPathSink des | this.asExpr() = des.getArgument(0)) }
}

class HttpServletRequest extends Class {
  HttpServletRequest() { this.hasQualifiedName("javax.servlet.http", "HttpServletRequest") }
}

class HttpServletRequestInput extends DataFlow::Node {
  HttpServletRequestInput() { this.asParameter().getType().(RefType) instanceof HttpServletRequest }
}

module JXPathUnsafeContextConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { exists(Parameter p | source.asParameter() = p) }

  predicate isSink(DataFlow::Node sink) { sink instanceof JXPathSinkHandlerInput }

  predicate isAdditionalFlowStep(DataFlow::Node source, DataFlow::Node sink) {
    exists(MethodCall call |
      call.getMethod().hasQualifiedName("it.eng.knowage.meta.service", "MetaService", "cleanPath") and
      call.getArgument(0) = source.asExpr() and
      call = sink.asExpr()
    )
  }
}

module MyFlow = TaintTracking::Global<JXPathUnsafeContextConfig>;

from MyFlow::PathNode source, MyFlow::PathNode sink
where MyFlow::flowPath(source, sink)
select sink, source, sink, "Unsafe deserialization of $@", sink, "user input"
