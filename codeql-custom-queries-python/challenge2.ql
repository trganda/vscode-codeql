/**
 * @kind problem
 * @desc Write a query to find all os.system method calls
 */

import python
import semmle.python.ApiGraphs

from API::CallNode node
where
    node = API::moduleImport("os").getMember("system").getACall()
select node, "Call to os.system"