/**
 * @name query for dubbo method
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java

from MethodAccess mcall
select mcall, "Call for " + mcall.getMethod().getName()