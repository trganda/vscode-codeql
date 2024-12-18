/**
 * @name query for dubbo method
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java

predicate isDeserialized(Expr qualifier) {
    exists(MethodAccess read, Method method |
        read.getMethod() = method and
        method.getName().matches("read%") and
        method.getDeclaringType().getASourceSupertype*().hasQualifiedName("org.apache.dubbo.common.serialize", "ObjectInput") and
        qualifier = read.getQualifier()
    )
}

from Expr expr
where isDeserialized(expr)
select expr, "Call for deserialization function."