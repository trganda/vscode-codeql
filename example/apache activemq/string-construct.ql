/**
 * @name query for string type construct
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/activemq
 */

import java

from Method m
select m, "Call for " + m.getName()
