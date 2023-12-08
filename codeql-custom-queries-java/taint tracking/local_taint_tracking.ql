/**
 * @name local data flow
 * @description a basic examples query of local data flow
 * @problem.severity warning
 * @id java/basic
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking

from Parameter src, Expr dst, Method m
where
m.getName() = "ttTest" and
m.getParameter(0).getName() = src.getName() and
TaintTracking::localTaint(DataFlow::parameterNode(src), DataFlow::exprNode(dst))
select m, dst, src
