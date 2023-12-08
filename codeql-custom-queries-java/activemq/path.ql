/**
 * @name query for activemq method
 * @kind path-problem
 * @problem.severity warning
 * @id org/trganda/java/path
 */

import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

class InsecureConfig extends TaintTracking::Configuration {
    InsecureConfig() {
        this = "InsecureConfig"
    }

    override predicate isSource(DataFlow::Node source) {
        exists(Method m|
            m.getName() = "unmarshal" and
            m.getDeclaringType().hasQualifiedName("org.apache.activemq.openwire", "OpenWireFormat") and
            m.getParameter(0) = source.asParameter()
            )
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(MethodCall call |
            call.getCallee().getName().matches("forName") and
            call.getCallee().getDeclaringType()
            .getASourceSupertype*().hasQualifiedName("java.lang", "Class") and
            call.getArgument(0) = sink.asExpr())
    }
}

from InsecureConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization $@", source.getNode(), "input"