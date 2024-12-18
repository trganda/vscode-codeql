/**
 * @name local data flow
 * @description a basic examples query of local data flow
 * @problem.severity warning
 * @id java/basic
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking

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

// and
// TaintTracking::localAdditionalTaintStep(source, sink, _) and
// call.getCallee().hasQualifiedName("it.eng.knowage.meta.service", "MetaService", "cleanPath") and call.getArgument(0) = source.asExpr() and call = sink.asExpr()

from Parameter src, Expr dst, Method method
where
  method.getParameter(0) = src and
  method.getName() = "applyPatch" and
  src.getType().(RefType).hasQualifiedName("com.fasterxml.jackson.databind", "JsonNode") and
  TaintTracking::localTaint(DataFlow::parameterNode(src), DataFlow::exprNode(dst))
select method, src, dst
