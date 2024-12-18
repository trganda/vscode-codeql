/**
 * @name query for string type construct
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/source
 */

import java
import semmle.code.java.frameworks.Networking

// from Method m
// where m.getName() = "tightUnmarshal" and
//     m.getDeclaringType().hasQualifiedName("org.apache.activemq.openwire.v1", "ExceptionResponseMarshaller")
// select m.getParameter(2), "Third Parameter of $@", m, m.getName()
from SocketGetInputStreamMethod m, MethodCall call
where call.getMethod() = m
select call.getQualifier(), "call for socket"