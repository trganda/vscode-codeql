/**
 * @name java.net.URL hard-coded query
 * @description finds all hard-coded strings used to create a java.net.URL
 * @kind path-problem
 * @problem.serverity warning
 * @id java/basic
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.StringFormat

from Constructor url, MethodAccess call, Expr formatString
where
  url.getDeclaringType().hasQualifiedName("java.net", "URL") and
  url = call.getCallee() and
  formatString instanceof StringLiteral and
  DataFlow::localFlow(DataFlow::exprNode(formatString), DataFlow::exprNode(call.getArgument(0)))
select call, "hard code to create java.net.URL"