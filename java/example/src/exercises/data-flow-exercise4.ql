/**
 * @id trganda/java/global-data-flow-ex4
 * @name Global Data Flow Exercise 4
 * @description Using the answers from 2 and 3, write a query which finds all global data flow paths from getenv to java.net.URL.
 * @kind problem
 * @tags data-flow, global-data-flow, java, exercise
 * @severity warning
 */

import java
import semmle.code.java.dataflow.DataFlow

class SystemGetEnvSource extends MethodCall {
  SystemGetEnvSource() {
    this.getMethod().getDeclaringType() instanceof TypeSystem and
    this.getMethod().getName() = "getenv"
  }
}

module HardCodeURLConfiguration implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(SystemGetEnvSource s | 
      s = source.asExpr()
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(ConstructorCall ctor |
      ctor.getCallee().getDeclaringType().hasQualifiedName("java.net", "URL") and
      ctor.getArgument(0) = sink.asExpr()
    )
  }
}

module HardCodeURLFlow = DataFlow::Global<HardCodeURLConfiguration>;

from DataFlow::Node source, DataFlow::Node sink
where HardCodeURLFlow::flow(source, sink)
select source, "Data flow to $@.", sink, sink.toString()
