/**
 * @name query for activemq method
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/gadget
 */

import java

from Class clazz, Constructor cons, RefType s
where cons.getNumberOfParameters() = 1 and
    cons.getParameterType(0) = s and
    s.hasQualifiedName("java.lang", "String") and
    clazz.getAConstructor() = cons and
    not clazz.getLocation().getFile().getRelativePath().matches("%/src/test/%")
select cons, "cons of $@", clazz, clazz.getQualifiedName()