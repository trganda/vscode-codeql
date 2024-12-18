/**
 * @name test
 * @kind problem
 * @problem.severity warning
 * @id java/test/spring/mapping
 */

import java
import SpringMVCMapping

from SpringControllerRequestMethod m
select m, m.getDescription()
 