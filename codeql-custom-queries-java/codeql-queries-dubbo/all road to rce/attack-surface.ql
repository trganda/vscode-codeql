/**
 * @name attack surface
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java
import semmle.code.java.dataflow.FlowSources

from RemoteFlowSource romteSource
where not romteSource.getLocation().getFile().getRelativePath().matches("%/src/test%")
select romteSource, romteSource.getEnclosingCallable().getDeclaringType(), romteSource.getSourceType()
