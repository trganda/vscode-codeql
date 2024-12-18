import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.frameworks.spring.SpringController

/** Annotation of spring web request */
class SpringRequestMappingAnnotation extends Annotation {
    SpringRequestMappingAnnotation() { this.getType() instanceof SpringRequestMappingAnnotationType }
}

/** 
 * A `SpringControllerMethod` that annotated with `SpringRequestMappingAnnotation`
 * */
class SpringControllerRequestMethod extends SpringControllerMethod {
    SpringControllerRequestMethod() {
        exists(Method superMethod |
            this.overrides*(superMethod) and
            superMethod.getAnAnnotation().getType() instanceof SpringRequestMappingAnnotationType
          )
    }

    private string getControllerMappedPath() {
        result = this.getDeclaringType().getAnAnnotation().(SpringRequestMappingAnnotation).getAnArrayValue(["value", "path"]).(StringLiteral).getValue()
    }

    private string getMethodMappedPath() {
        result = this.getAnAnnotation().(SpringRequestMappingAnnotation).getAnArrayValue(["value", "path"]).(StringLiteral).getValue()
    }

    bindingset[path]
    private string formatMappedPath(string path){
        (path.matches("/%") and path.matches("%/") and result = path.prefix(path.length() - 1))
        or
        (path.matches("/%") and not path.matches("%/") and result = path)
        or
        (not path.matches("/%") and path.matches("%/") and result = "/" +  path.prefix(path.length() - 1))
        or
        (not path.matches("/%") and not path.matches("%/") and result = "/" + path)
    }

    string getMappedPath() {
        result = (formatMappedPath(getControllerMappedPath()) + formatMappedPath(getMethodMappedPath())).replaceAll("//", "/") 
    }
}

private class MethodDescAnnotation extends Annotation {
    MethodDescAnnotation() {
        this.getType().getQualifiedName()=["io.swagger.annotiation.ApiOperation"]
    }
}