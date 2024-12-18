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
            m.getParameter(2) = source.asParameter())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(Call call |
            call.getCallee().getName().matches("tightUnmarsalThrowable%") and
            call.getCallee().getDeclaringType()
            .getASourceSupertype*().hasQualifiedName("org.apache.activemq.openwire.v1", "BaseDataStreamMarshaller") and
            call.getQualifier() = sink.asExpr())
    }
}

from InsecureConfig conf, DataFlow::Node source, DataFlow::Node sink
where conf.hasFlow(source, sink)
select sink, source, sink, "Unsafe class.forName $@", source, "input"
