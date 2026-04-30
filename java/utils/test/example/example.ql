/**
 * @id java/example/example
 * @name springmvc-mapping-result
 * @description Finds Spring MVC controller request mappings and their mapped paths.
 * @kind table
 * @tags example
 */

import java
import frameworks.spring.SpringMVCMapping

from SpringRestEndpoint m
select m, m.getMappedPath(), m.getDeclaringType().getPackage().getName()