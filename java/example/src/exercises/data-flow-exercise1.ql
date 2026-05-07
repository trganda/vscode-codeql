/**
 * @id trganda/java/local-data-flow-ex1
 * @name Local Data Flow Exercise 1
 * @description Write a query that finds all hard-coded strings used to create a java.net.URL, using local data flow.
 * @kind problem
 * @tags data-flow, local-data-flow, java, exercise
 * @severity warning
 */

import java
import semmle.code.java.dataflow.DataFlow

from StringLiteral source, Call sink, Constructor ctor
where
  ctor.getDeclaringType().hasQualifiedName("java.net", "URL") and 
  sink.getCallee() = ctor and
  DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(sink.getArgument(0)))
select source, "This method call is using a hardcoded string to create a URL"