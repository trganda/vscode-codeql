/**
 * @name Openwire Injection
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @id java/file-path-injection
 */

import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.frameworks.Networking
import InjectFilePathFlow::PathGraph

class SocketDataInputStreamVariable extends Variable {
  SocketDataInputStreamVariable() {
    exists(RefType ref, SocketGetInputStreamMethod socketIn, Call callSocketIn, VariableUpdate expr |
      ref.hasQualifiedName("java.io", "DataInputStream") and
      this.getType() = ref and
      callSocketIn.getCallee() = socketIn and
      expr.getDestVar() = this and
      TaintTracking::localTaint(DataFlow::exprNode(callSocketIn), DataFlow::exprNode(expr))
    )
  }
}

module InjectFilePathConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(SocketDataInputStreamVariable dataIn, VarRead read |
      source.asExpr() = read and
      read.getVariable() = dataIn
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(MethodCall call |
      call.getCallee().getName().matches("forName") and
      call.getCallee()
          .getDeclaringType()
          .getASourceSupertype*()
          .hasQualifiedName("java.lang", "Class") and
      call.getArgument(0) = sink.asExpr()
    )
  }
}

module InjectFilePathFlow = TaintTracking::Global<InjectFilePathConfig>;

from InjectFilePathFlow::PathNode source, InjectFilePathFlow::PathNode sink
where InjectFilePathFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "External control of file name or path due to $@.",
  source.getNode(), "user-provided value"
