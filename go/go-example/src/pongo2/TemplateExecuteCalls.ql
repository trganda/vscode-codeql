/**
 * @id trganda/go-example/pongo2-template-execute-calls
 * @name Calls to (*pongo2.Template).Execute
 * @description Finds calls to (*pongo2.Template).Execute, which renders a
 *              parsed template against a context and may be a sink for
 *              template-injection taint when the template body is
 *              attacker-controlled.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags go-example
 */

import go
import Pongo2

from DataFlow::CallNode call, Method m
where
  m.hasQualifiedName(Pongo2::packagePath(), "Template", "Execute") and
  call = m.getACall()
select call, "Call to (*pongo2.Template).Execute."
