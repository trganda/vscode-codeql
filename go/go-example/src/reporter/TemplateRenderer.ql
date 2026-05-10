/**
 * @id trganda/go-example/templaterenderer
 * @name TemplateRenderer.RenderFromBytes calls
 * @description Finds calls to (*TemplateRenderer).RenderFromBytes.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags go-example
 */

import go

from DataFlow::CallNode call, Method m
where
  m.hasQualifiedName(_, "TemplateRenderer", "RenderFromBytes") and
  call = m.getACall()
select call, "Call to (*TemplateRenderer).RenderFromBytes."