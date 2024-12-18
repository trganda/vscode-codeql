/**
 * @name query for activemq method
 * @kind path-problem
 * @problem.severity warning
 * @id org/trganda/java/activemq
 */

import java
import semmle.code.java.dataflow.FlowSources
import DataFlow::PathGraph

class InsecureConfig extends TaintTracking::Configuration {
    InsecureConfig() {
        this = "InsecureConfig"
    }

    override predicate isSource(DataFlow::Node source) {
        exists(Method m |
            m.getName() = "tightUnmarshal" and
            m.getDeclaringType().hasQualifiedName("org.apache.activemq.openwire.v1", "ExceptionResponseMarshaller") and
            m.getParameter(3) = source.asParameter())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(Call call |
            call.getCallee().getName().matches("createThrowable%") and
            call.getCallee().getDeclaringType()
            .getASourceSupertype*().hasQualifiedName("org.apache.activemq.openwire.v1", "BaseDataStreamMarshaller") and
            call.getQualifier() = sink.asExpr())
    }

    // override predicate isAdditionalTaintStep(DataFlow::Node source, DataFlow::Node sink) {
    //     exists(MethodAccess ma |
    //         ma.getMethod().getName() = "deserialize" and
    //         ma.getMethod().getDeclaringType().hasQualifiedName("org.apache.dubbo.common.serialize", "Serialization") and
    //         ma.getArgument(1) = source.asExpr() and
    //         ma = sink.asExpr())
    // }
}

from InsecureConfig conf, DataFlow::PathNode source, DataFlow::PathNode sink
where conf.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe class.forName $@", source.getNode(), "input"
