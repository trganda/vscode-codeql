/**
 * @name Spring REST API endpoint methods
 * @description Finds methods annotated with Spring REST API mapping annotations
 *              and reports their name, HTTP method, path, and parameter info.
 * @kind problem
 * @problem.severity recommendation
 * @precision high
 * @id java/spring-rest-endpoints
 * @tags maintainability
 */

import java
import semmle.code.java.frameworks.SpringWeb

/**
 * Gets the HTTP method name for a SpringRequestMappingMethod.
 * Handles both @RequestMapping(method=...) and shorthand annotations
 * like @GetMapping, @PostMapping, etc.
 */
string getHttpMethod(SpringRequestMappingMethod m) {
  result = m.getMethodValue()
  or
  not exists(m.getMethodValue()) and
  (
    m.getAnAnnotation().getType().hasName("GetMapping") and result = "GET"
    or
    m.getAnAnnotation().getType().hasName("PostMapping") and result = "POST"
    or
    m.getAnAnnotation().getType().hasName("PutMapping") and result = "PUT"
    or
    m.getAnAnnotation().getType().hasName("DeleteMapping") and result = "DELETE"
    or
    m.getAnAnnotation().getType().hasName("PatchMapping") and result = "PATCH"
    or
    not m.getAnAnnotation()
        .getType()
        .hasName(["GetMapping", "PostMapping", "PutMapping", "DeleteMapping", "PatchMapping"]) and
    result = "ANY"
  )
}

/**
 * Gets the mapped path for a SpringRequestMappingMethod.
 * Falls back to "(no explicit path)" when no method-level path is set.
 */
string getMappingPath(SpringRequestMappingMethod m) {
  result = m.getAValue()
  or
  not exists(m.getAValue()) and result = "(no explicit path)"
}

/**
 * Describes a single parameter: its position, type, name, and any binding annotation.
 */
string describeParam(Parameter p) {
  exists(string annotation |
    (
      p.getAnAnnotation().getType().hasName("RequestParam") and annotation = "@RequestParam"
      or
      p.getAnAnnotation().getType().hasName("PathVariable") and annotation = "@PathVariable"
      or
      p.getAnAnnotation().getType().hasName("RequestBody") and annotation = "@RequestBody"
      or
      p.getAnAnnotation().getType().hasName("RequestHeader") and annotation = "@RequestHeader"
      or
      p.getAnAnnotation().getType().hasName("CookieValue") and annotation = "@CookieValue"
      or
      p.getAnAnnotation().getType().hasName("MatrixVariable") and annotation = "@MatrixVariable"
      or
      p.getAnAnnotation().getType().hasName("ModelAttribute") and annotation = "@ModelAttribute"
      or
      p.getAnAnnotation().getType().hasName("RequestPart") and annotation = "@RequestPart"
      or
      not exists(p.getAnAnnotation()) and annotation = "(no annotation)"
    ) and
    result =
      annotation + " " + p.getType().getName() + " " + p.getName() + " [index=" +
        p.getPosition() + "]"
  )
}

from SpringRequestMappingMethod m, Parameter p
where
  p = m.getAParameter() and
  // Only include methods with at least one parameter; for parameter-less
  // methods a companion query variant (below) handles those separately.
  m.fromSource()
select m,
  "Method: " + m.getName() + " | HTTP: " + getHttpMethod(m) + " | Path: " + getMappingPath(m) +
    " | Class: " + m.getDeclaringType().getQualifiedName() + " | Param: " + describeParam(p)
