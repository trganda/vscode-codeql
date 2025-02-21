import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.frameworks.spring.SpringController

/** 
 * Annotation of spring web request mapping
 */
class SpringRequestMappingAnnotation extends Annotation {
    SpringRequestMappingAnnotation() { this.getType() instanceof SpringRequestMappingAnnotationType }
}

/**
 * Annotation of swagger api operation `io.swagger.annotations.ApiOperation`
 */
class SwaggerApiOpAnnotation extends Annotation {
    SwaggerApiOpAnnotation() {
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

    // Get the path value of the controller class
    private string getControllerMappedPath() {
        (result = this.getDeclaringType().getAnAnnotation().(SpringRequestMappingAnnotation).getStringValue("value") and result.length() > 0)
        or
        (result = this.getDeclaringType().getAnAnnotation().(SpringRequestMappingAnnotation).getStringValue("path") and result.length() > 0)
        or
        (result = this.getDeclaringType().getAnAnnotation().(SpringRequestMappingAnnotation).getAStringArrayValue(["value", "path"]) and result.length() > 0)
    }

    // Get the path value of the method
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

    // Get the description of the api operation
    string getDescription() {
        (result = this.getAnAnnotation().(SwaggerApiOpAnnotation).getStringValue("value") and result.length() > 0)
        or
        (result = this.getAnAnnotation().(SwaggerApiOpAnnotation).getStringValue("notes") and result.length() > 0)
        or
        (result = this.getAnAnnotation().(SwaggerApiOpAnnotation).getAStringArrayValue(["value", "notes"]) and result.length() > 0)
    }
}