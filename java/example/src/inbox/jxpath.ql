/**
 * @name JXPath
 * @kind problem
 * @problem.severity warning
 * @id java/inbox/jxpath
 */

import java

class JXPathContext extends Class {
    JXPathContext() {
    this.hasQualifiedName("org.apache.commons.jxpath", "JXPathContext")
  }
}

class JXPathSink extends MethodCall {
    JXPathSink() {
    this.getCallee().getDeclaringType().getASupertype*() instanceof JXPathContext and
    this.getCallee().getName() = "getPointer"
  }
}

from JXPathSink ccall
select ccall.getArgument(0), ccall.getCallee().getName()