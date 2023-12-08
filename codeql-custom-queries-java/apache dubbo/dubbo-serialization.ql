/**
 * @name query for dubbo class that implement Serialization
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java

from Class c, Interface i
where c.getASupertype+() = i and i.hasQualifiedName("org.apache.dubbo.common.serialize", "Serialization")
select c, "Implementation of Serialization"