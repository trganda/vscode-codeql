/**
 * @name Example of query for the spring mvc controller mapping path
 * @kind problem
 * @problem.severity warning
 * @id java/test/spring/mapping
 */

import java
import SpringMVCMapping

from SpringControllerRequestMethod m
select m, m.getMappedPath()
