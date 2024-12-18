/**
 * @name query for activemq method
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/activemq
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.frameworks.Networking

from Variable dataIn, RefType ref, SocketGetInputStreamMethod socketIn, Call callSocketIn, VariableUpdate expr
where dataIn.getType() = ref
    and ref.hasQualifiedName("java.io", "DataInputStream")
    and callSocketIn.getCallee() = socketIn
    and expr.getDestVar() = dataIn
    and TaintTracking::localTaint(DataFlow::exprNode(callSocketIn), DataFlow::exprNode(expr))
select dataIn, "dataIn with type $@", ref, ref.getName()