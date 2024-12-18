/**
 * @name query for activemq method
 * @kind problem
 * @problem.severity warning
 * @id com/trganda/java/step2
 */

import java

from Class httpParameter, Method appendAll, MethodCall callAppendAll
where appendAll.getDeclaringType() = httpParameter
    and httpParameter.hasQualifiedName("org.apache.struts2.dispatcher", "HttpParameters")
    and callAppendAll.getCallee() = appendAll
    and appendAll.getName() = "appendAll"
select callAppendAll, "Call $@", appendAll, appendAll.getName()