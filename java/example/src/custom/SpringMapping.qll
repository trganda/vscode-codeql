import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.frameworks.spring.SpringController


private class MappingAnnotation extends Annotation {
    MappingAnnotation() {
        this.getType().getQualifiedName() = [
            "org.springframework.web.bind.annotation.RequestMapping",
            "org.springframework.web.bind.annotation.GetMapping",
            "org.springframework.web.bind.annotation.PostMapping",
            "org.springframework.web.bind.annotation.PutMapping",
            "org.springframework.web.bind.annotation.DeleteMapping"
        ]
    }
}

class MappingMethod extends Method {
    MappingMethod() {
        this instanceof Method and this.fromSource()
    }

    Class getController() {
        result = this.getDeclaringType()
    }

    string getControllerMappedPath() {
        if getController().getAnAnnotation() instanceof MappingAnnotation then
            result = getController().getAnAnnotation().(MappingAnnotation).getAnArrayValue(["value", "path"]).(StringLiteral).getValue()
        else
            result = ""
    }

    string getMethodMappedPath() {
        result = this.getAnAnnotation().(MappingAnnotation).getAnArrayValue(["value", "path"]).(StringLiteral).getValue()
    }

    bindingset[path]

    private string formatMappedPath(string path){
        (path.matches("/%") and path.matches("%/") and result = path.prefix(path.length()-1))
        or
        (path.matches("/%") and not path.matches("%/") and result = path)
        or
        (not path.matches("/%") and path.matches("%/") and result = "/" +  path.prefix(path.length()-1))
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
