/**
 * @name query for activemq method
 * @kind path-problem
 * @problem.severity warning
 * @id com/trganda/java/step2
 */

import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.frameworks.Networking
import semmle.code.java.dataflow.ExternalFlow
import semmle.code.java.dataflow.FlowSources

class WireFormat extends Class {
    WireFormat() {
        this.getASupertype*().hasQualifiedName("org.apache.activemq.wireformat", "WireFormat")
    }
}

module MyFlowConfiguration implements DataFlow::ConfigSig {
    predicate isSource(DataFlow::Node source) {
        exists(Method m, WireFormat wm|
            m.getName() = "unmarshal" and
            m.getDeclaringType() = wm and
            m.getParameter(0) = source.asParameter()
        )
    }

    predicate isSink(DataFlow::Node sink) {
        exists(MethodCall call |
            call.getCallee().getName().matches("forName") and
            call.getCallee().getDeclaringType()
            .getASourceSupertype*().hasQualifiedName("java.lang", "Class") and
            call.getArgument(0) = sink.asExpr()
        )
    }
}

module MyFlow = TaintTracking::Global<MyFlowConfiguration>;

from MyFlow::PathNode source, MyFlow::PathNode sink
where MyFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Data flow to $@.", 
    source.getNode(), "user-provided value"