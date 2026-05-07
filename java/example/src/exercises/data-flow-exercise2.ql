/**
 * @id trganda/java/global-data-flow-ex2
 * @name Global Data Flow Exercise 2
 * @description Write a query that finds all hard-coded strings used to create a java.net.URL, using global data flow.
 * @kind problem
 * @tags data-flow, global-data-flow, java, exercise
 * @severity warning
 */

import java
import semmle.code.java.dataflow.DataFlow

module HardCodeURLConfiguration implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof StringLiteral
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
