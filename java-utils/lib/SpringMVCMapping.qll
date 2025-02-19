import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.frameworks.spring.SpringController

/** Annotation of spring web request */
class SpringRequestMappingAnnotation extends Annotation {
    SpringRequestMappingAnnotation() { this.getType() instanceof SpringRequestMappingAnnotationType }
}

class MethodDescAnnotation extends Annotation {
    MethodDescAnnotation() {
        this.getType().hasQualifiedName("io.swagger.annotations", "ApiOperation")
    }
}

/** 
 * A `SpringControllerMethod` that annotated with `SpringRequestMappingAnnotation`
 */
class SpringControllerRequestMethod extends SpringControllerMethod {
    SpringControllerRequestMethod() {
        exists(Method superMethod |
            this.overrides*(superMethod) and
            superMethod.getAnAnnotation().getType() instanceof SpringRequestMappingAnnotationType
          )
    }

    private string getControllerMappedPath() {
        (result = this.getDeclaringType().getAnAnnotation().(SpringRequestMappingAnnotation).getStringValue("value") and result.length() > 0)
        or
        (result = this.getDeclaringType().getAnAnnotation().(SpringRequestMappingAnnotation).getStringValue("path") and result.length() > 0)
        or
        (result = this.getDeclaringType().getAnAnnotation().(SpringRequestMappingAnnotation).getAStringArrayValue(["value", "path"]) and result.length() > 0)
    }

    private string getMethodMappedPath() {
        (result = this.getAnAnnotation().(SpringRequestMappingAnnotation).getStringValue("value") and result.length() > 0)
        or
        (result = this.getAnAnnotation().(SpringRequestMappingAnnotation).getStringValue("path") and result.length() > 0)
        or
        (result = this.getAnAnnotation().(SpringRequestMappingAnnotation).getAStringArrayValue(["value", "path"]) and result.length() > 0)
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

    string getDescription() {
        (result = this.getAnAnnotation().(MethodDescAnnotation).getStringValue("value") and result.length() > 0)
        or
        (result = this.getAnAnnotation().(MethodDescAnnotation).getStringValue("notes") and result.length() > 0)
        or
        (result = this.getAnAnnotation().(MethodDescAnnotation).getAStringArrayValue(["value", "notes"]) and result.length() > 0)
    }
}