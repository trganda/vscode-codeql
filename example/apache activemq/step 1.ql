/**
 * @name query for activemq method
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/test
 */

import java
import semmle.code.java.dataflow.TaintTracking

module MyFlowConfiguration implements DataFlow::ConfigSig {
    predicate isSource(DataFlow::Node source) {
        exists(Method m|
            m.getName() = "unmarshal" and
            m.getDeclaringType().hasQualifiedName("org.apache.activemq.openwire", "OpenWireFormat") and
            m.getParameter(0) = source.asParameter()
            )
    }

    predicate isSink(DataFlow::Node sink) {
        exists(MethodCall call |
            call.getCallee().getName().matches("forName") and
            call.getCallee().getDeclaringType()
            .getASourceSupertype*().hasQualifiedName("java.lang", "Class") and
            call.getArgument(0) = sink.asExpr())
    }
}

module MyFlow = TaintTracking::Global<MyFlowConfiguration>;
from DataFlow::Node source, DataFlow::Node sink
where MyFlow::flow(source, sink)
select source, "Data flow to $@.", sink, sink.toString()