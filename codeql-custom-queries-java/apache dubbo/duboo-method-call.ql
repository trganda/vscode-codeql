/**
 * @name query for dubbo method
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java

from MethodAccess mcall, Method m
where m = mcall.getMethod()
select m, "Call for " + m.getName()