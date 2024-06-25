/**
 * @kind problem
 * @problem.severity error
 * @id codeql-zero-to-hero/8
 */
import python
import semmle.python.dataflow.new.RemoteFlowSources

from RemoteFlowSource rfs
select rfs, "A remote flow source"