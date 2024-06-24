/**
 * @kind problem
 * @desc Write a query to find all Flask requests
 */

import python
import semmle.python.ApiGraphs

select API::moduleImport("flask").getMember("request").getMember("args").asSource(), "Flask request.args source"