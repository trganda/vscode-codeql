/**
 * @name query for implementation of ExpressionEngine
 * @kind problem
 */

import java

from Class clazz
where clazz.getASupertype*().hasQualifiedName("org.apache.commons.configuration2.tree", "ExpressionEngine")
select clazz, "Implemented ExpressionEngine"