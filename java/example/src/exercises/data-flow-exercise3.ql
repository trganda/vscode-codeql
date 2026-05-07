/**
 * @id trganda/java/local-data-flow-ex3
 * @name Local Data Flow Exercise 3
 * @description Write a class that represents flow sources from java.lang.System.getenv(..)
 * @kind problem
 * @tags data-flow, local-data-flow, java, exercise
 * @severity warning
 */

import java

class SystemGetEnvSource extends MethodCall {
  SystemGetEnvSource() {
    this.getMethod().getDeclaringType() instanceof TypeSystem and
    this.getMethod().getName() = "getenv"
  }
}

from SystemGetEnvSource source
select source, "Method call of java.lang.System.getenv(..)"