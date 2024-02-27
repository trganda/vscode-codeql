/**
 * @name Http Handler
 * @kind problem
 * @problem.severity warning
 * @id go/example/empty-block
 */

import go
import semmle.go.concepts.HTTP

from Http::ResponseWriter rsp
select rsp, "This is an http response."