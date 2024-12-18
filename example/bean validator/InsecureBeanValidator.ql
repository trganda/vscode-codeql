/**
 * @name Insecure Bean Validation
 * @description User-controlled data may be evaluated as a Java EL expression, leading to arbitrary code execution.
 * @kind path-problem
 * @problem.severity warning
 * @id com/github/trganda/insecure-bean-validation
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources
import BeanValidation::PathGraph

class TypeConstraintValidator extends RefType {
  TypeConstraintValidator() { this.hasQualifiedName("javax.validation", "ConstraintValidator") }
}

class ConstraintValidatorIsValidMethod extends Method {
  ConstraintValidatorIsValidMethod() {
    exists(Method m |
      m.hasName("isValid") and
      m.getDeclaringType() instanceof TypeConstraintValidator and
      this = m.getAPossibleImplementation()
    )
  }
}

class InsecureBeanValidationSource extends RemoteFlowSource {
  InsecureBeanValidationSource() {
    // exists(ConstraintValidatorIsValidMethod m | this.asParameter() = m.getParameter(0))
    this.asParameter() = any(ConstraintValidatorIsValidMethod m).getParameter(0)
  }

  override string getSourceType() { result = "Insecure Bean Validation Source" }
}

class TypeConstraintValidatorContext extends RefType {
  TypeConstraintValidatorContext() {
    this.hasQualifiedName("javax.validation", "ConstraintValidatorContext")
  }
}

class BuildConstraintViolationWithTemplateMethod extends Method {
  BuildConstraintViolationWithTemplateMethod() {
    hasName("buildConstraintViolationWithTemplate") and
    getDeclaringType().getASupertype*() instanceof TypeConstraintValidatorContext
  }
}

class BuildConstraintViolationWithTemplateSink extends DataFlow::ExprNode {
  BuildConstraintViolationWithTemplateSink() {
    exists(MethodCall ma |
      this.asExpr() = ma.getArgument(0) and
      ma.getMethod() instanceof BuildConstraintViolationWithTemplateMethod
    )
  }
}

class ExceptionMessageMethod extends Method {
  ExceptionMessageMethod() {
    (
      this.hasName("getMessage") or
      this.hasName("getLocalizedMessage") or
      this.hasName("toString")
    ) and
    getDeclaringType().getASourceSupertype*() instanceof TypeThrowable
  }
}

module BeanValidationConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof InsecureBeanValidationSource }

  predicate isSink(DataFlow::Node sink) { sink instanceof BuildConstraintViolationWithTemplateSink }

  predicate isAdditionalFlowStep(DataFlow::Node n1, DataFlow::Node n2) {
    exists(Call call, TryStmt t, CatchClause c, MethodCall gm |
      call.getEnclosingStmt().getEnclosingStmt*() = t.getBlock() and
      t.getACatchClause() = c and
      (
        call.getCallee().getAThrownExceptionType().getASubtype*() = c.getACaughtType() or
        c.getACaughtType().getASupertype*() instanceof TypeRuntimeException
      ) and
      c.getVariable().getAnAccess() = gm.getQualifier() and
      gm.getMethod() instanceof ExceptionMessageMethod and
      n1.asExpr() = call.getAnArgument() and
      n2.asExpr() = gm
    )
  }
}

module BeanValidation = TaintTracking::Global<BeanValidationConfig>;

from BeanValidation::PathNode source, BeanValidation::PathNode sink
where BeanValidation::flowPath(source, sink)
select sink, source, sink, "Template Injection of $@", sink, "user input"
