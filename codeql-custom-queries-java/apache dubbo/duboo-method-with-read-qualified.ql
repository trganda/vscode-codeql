/**
 * @name query for dubbo method
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java

from MethodAccess mcall, Method m, Expr expr
where m = mcall.getMethod() and 
    m.getName().matches("read%") and
    m.getDeclaringType().getASourceSupertype*().hasQualifiedName("org.apache.dubbo.common.serialize", "ObjectInput") and
    expr = mcall.getQualifier()
select expr, "Call for " + m.getName()