/**
 * @name java.net.URL hard-coded query
 * @description finds all hard-coded strings used to create a java.net.URL
 * @kind path-problem
 * @problem.severity warning
 * @id java/url_hardcode
 */

import java
import semmle.code.java.dataflow.DataFlow
import DataFlow::PathGraph

class URLHardCodeConfiguration extends DataFlow::Configuration {
  URLHardCodeConfiguration() {
    this = "URLHardCodeConfiguration"
  }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof StringLiteral
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(ConstructorCall cc | cc.getConstructedType().hasQualifiedName("java.net", "URL") and cc.getArgument(0) = sink.asExpr())
  }
}

from URLHardCodeConfiguration cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Hardcode $@", source.getNode(), "URL arugment"