/**
 * @name query for dubbo method
 * @kind path-problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

/**
 * Identifying the interface org.apache.dubbo.remoting.Codec2
 */
class DubboCodec extends RefType {
    DubboCodec() {
        this.hasQualifiedName("org.apache.dubbo.remoting", "Codec2")
    }
}

/**
 * Identfying Methods called decodeBody on classes whose direct super-types include DubboCodec.
 */
class DubboCodecDecodeBody extends Method {
    DubboCodecDecodeBody() {
        this.hasName("decodeBody") and
        this.getDeclaringType().getASupertype*() instanceof DubboCodec
    }

    Parameter getAnUntrustParameter() {
        result = this.getParameter([1,2])
    }
}

predicate isDeserialized(Expr qualifier) {
    exists(MethodAccess read, Method method |
        read.getMethod() = method and
        method.getName().matches("read%") and
        method.getDeclaringType().getASourceSupertype*().hasQualifiedName("org.apache.dubbo.common.serialize", "ObjectInput") and
        qualifier = read.getQualifier()
    )
}

class DubboUnsafeDeserializationConfig extends TaintTracking::Configuration {
    DubboUnsafeDeserializationConfig() { this = "DubboUnsafeDeserializationConfig" }
    override predicate isSource(DataFlow::Node source) {
      exists(DubboCodecDecodeBody decode |
        source.asParameter() = decode.getAnUntrustParameter()
      )
    }
    override predicate isSink(DataFlow::Node sink) {
        isDeserialized(sink.asExpr())
    }
    override predicate isAdditionalTaintStep(DataFlow::Node n1, DataFlow::Node n2) {
        exists(MethodAccess call |
            call.getMethod().getName() = "deserialize" and
            call.getMethod().getDeclaringType().getName() = "Serialization" and
            call.getArgument(1) = n1.asExpr() and
            call = n2.asExpr()
        )
    }
}


from DubboUnsafeDeserializationConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization $@", source.getNode(), "input"
