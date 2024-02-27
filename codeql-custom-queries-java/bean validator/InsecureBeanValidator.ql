/**
 * @name Insecure Bean Validation
 * @description User-controlled data may be evaluated as a Java EL expression, leading to arbitrary code execution.
 * @kind path-problem
 * @problem.severity warning
 * @id java/el/insecure-bean-validation
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources

class TypeConstraintValidator extends RefType {
  TypeConstraintValidator() { hasQualifiedName("javax.validation", "ConstraintValidator") }
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
    exists(ConstraintValidatorIsValidMethod m | this.asParameter() = m.getParameter(0))
  }

  override string getSourceType() { result = "Insecure Bean Validation Source" }
}

class TypeConstraintValidatorContext extends RefType {
  TypeConstraintValidatorContext() {
    hasQualifiedName("javax.validation", "ConstraintValidatorContext")
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
    exists(MethodAccess ma |
      asExpr() = ma.getArgument(0) and
      ma.getMethod() instanceof BuildConstraintViolationWithTemplateMethod
    )
  }
}

class ExceptionMessageMethod extends Method {
  ExceptionMessageMethod() {
    (
      hasName("getMessage") or
      hasName("getLocalizedMessage") or
      hasName("toString")
    ) and
    getDeclaringType().getASourceSupertype*() instanceof TypeThrowable
  }
}

class ExceptionTaintStep extends TaintTracking::AdditionalTaintStep {
  override predicate step(DataFlow::Node n1, DataFlow::Node n2) {
    exists(Call call, TryStmt t, CatchClause c, MethodAccess gm |
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

class BeanValidationConfig extends TaintTracking::Configuration {
  BeanValidationConfig() { this = "BeanValidationConfig" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof InsecureBeanValidationSource
  }

  override predicate isSink(DataFlow::Node sink) {
    sink instanceof BuildConstraintViolationWithTemplateSink
  }
}

from BeanValidationConfig conf, DataFlow::PathNode source, DataFlow::PathNode sink
where conf.hasFlowPath(source, sink)
select source, sink, "Unsafe deserialization"
