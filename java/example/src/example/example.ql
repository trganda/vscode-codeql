/**
 * @id java/example/example
 * @name example
 * @description Replace this text with a description of your query.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags example
 */

import java
import lib.SpringMVCMapping

from SpringControllerRequestMethod m
select m, m.getMappedPath()

