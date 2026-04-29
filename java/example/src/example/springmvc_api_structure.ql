/**
 * @id java/example/springmvc-api-structure
 * @name Spring MVC REST API structure
 * @description Reports the full REST API structure of Spring MVC controllers:
 *              path, HTTP method, and per-parameter kind/name/type/required status.
 * @kind table
 * @tags example
 */

import java
import frameworks.spring.SpringMVCMapping

from SpringRestEndpoint m, SpringRestParameter p, string required
where
    p = m.getAParameter() and
    (p.isRequired() and required = "true" or not p.isRequired() and required = "false")
select
    m, 
    m.getMappedPath() as path,
    m.getHttpMethod() as httpMethod,
    p.getKind() as paramKind,
    p.getAPIParameterName() as paramName,
    p.getType().getName() as paramType,
    required
