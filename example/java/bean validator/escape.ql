/**
 * @name Insecure Bean Validation
 * @description User-controlled data may be evaluated as a Java EL expression, leading to arbitrary code execution.
 * @kind problem
 * @problem.severity warning
 * @id java/el/insecure-bean-validation
 */


import java

class EscapeMethod extends Method {
    
    EscapeMethod() {
        this.getName() = "stripJavaEl" and 
        this.getDeclaringType().hasQualifiedName("org.sonatype.nexus.common.template", "EscapeHelper")
    }
}

from EscapeMethod m, MethodCall call
where call.getMethod() = m
select call, "Call for stripJavaEl"