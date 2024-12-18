/**
 * @name Query for MVEL Expression Execution
 * @description Find the call path to mvel expression execution
 * @id com/trganda/unomi
 * @kind path-problem
 */

import java
import semmle.code.java.dataflow.DataFlow

class MvelExpressionExecuter extends DataFlow::Node {
    MvelExpressionExecuter() {
        
    }
}

module MvelUnsafeExpressionExecutionConfig implements DataFlow::ConfigSig {
    predicate isSource(DataFlow::Node source) {
        
    }

    predicate isSink(DataFlow::Node sink) {
        
    }
}