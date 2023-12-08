/**
 * @name query for string type construct
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/activemq
 */

import java

from Call call
where call.getCallee().getName().matches("tightUnmarsalThrowable") and 
    call.getCallee().getDeclaringType().getASourceSupertype*().hasQualifiedName("org.apache.activemq.openwire.v1", "BaseDataStreamMarshaller")
select call, "Call for " + call.getCallee().getName()
