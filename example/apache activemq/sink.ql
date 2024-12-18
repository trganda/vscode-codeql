/**
 * @name query for activemq method
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/activemq
 */

import java

from Method m, Call call, Class c
where m.getDeclaringType() = c 
    and m.getName() = "createThrowable"
    and call.getCaller() = m
    and call.getCallee().getDeclaringType().hasQualifiedName("java.lang", "Class")
    and call.getCallee().getName() = "forName"
    and c.hasQualifiedName("org.apache.activemq.openwire.v1", "BaseDataStreamMarshaller")
select m, "Method call Class.forName"