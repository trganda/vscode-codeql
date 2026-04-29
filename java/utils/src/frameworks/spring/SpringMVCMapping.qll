import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.frameworks.spring.SpringController

/**
 * An `AnnotationType` that is used to indicate a `RequestMapping`.
 */
class SpringRequestMappingAnnotationType extends AnnotationType {
  SpringRequestMappingAnnotationType() {
    // `@RequestMapping` used directly as an annotation.
    this.hasQualifiedName("org.springframework.web.bind.annotation", "RequestMapping")
    or
    // `@RequestMapping` can be used as a meta-annotation on other annotation types, e.g. GetMapping, PostMapping etc.
    this.getAnAnnotation().getType() instanceof SpringRequestMappingAnnotationType
  }
}

/**
 * Annotation of spring web request mapping
 */
class SpringRequestMappingAnnotation extends Annotation {
  SpringRequestMappingAnnotation() { this.getType() instanceof SpringRequestMappingAnnotationType }
}

/**
 * An `AnnotationType` that is used to indicate a swagger API operation annotation.
 */
class SwaggerApiOpAnnotationType extends AnnotationType {
  SwaggerApiOpAnnotationType() { this.hasQualifiedName("io.swagger.annotations", "ApiOperation") }
}

/**
 * Annotation of swagger api operation `io.swagger.annotations.ApiOperation`
 */
class SwaggerApiOpAnnotation extends Annotation {
  SwaggerApiOpAnnotation() { this.getType() instanceof SwaggerApiOpAnnotationType }
}

/**
 * An `AnnotationType` that is used to indicate a spring web request parameter mapping, e.g. `@RequestParam`, `@PathVariable`, `@RequestBody`, `@RequestHeader`.
 */
class SpringRequestparamAnnotationType extends AnnotationType {
  SpringRequestparamAnnotationType() {
    this.hasQualifiedName("org.springframework.web.bind.annotation", "RequestParam")
  }
}

class SpringRequestParamAnnotation extends Annotation {
  SpringRequestParamAnnotation() { this.getType() instanceof SpringRequestparamAnnotationType }

  // Spring allows @RequestParam to specify the parameter name using either "value" or "name", with no default value, get one of them when present
  string getParamName() {
    result = this.getStringValue("value") and result.length() > 0
    or
    result = this.getStringValue("name") and result.length() > 0
  }

  string getDefaultValue() { result = this.getStringValue("defaultValue") }

  // Spring default for required is true; only not required when explicitly false
  predicate isRequired() {
    not this.getValue("required").(BooleanLiteral).getBooleanValue() = false
  }
}

/**
 * An `AnnotationType` that is used to indicate a spring web path variable mapping, i.e. `@PathVariable`.
 */
class SpringPathVariableAnnotationType extends AnnotationType {
  SpringPathVariableAnnotationType() {
    this.hasQualifiedName("org.springframework.web.bind.annotation", "PathVariable")
  }
}

class SpringPathVariableAnnotation extends Annotation {
  SpringPathVariableAnnotation() { this.getType() instanceof SpringPathVariableAnnotationType }

  string getParamName() {
    result = this.getStringValue("value") and result.length() > 0
    or
    result = this.getStringValue("name") and result.length() > 0
  }

  // Spring default for required is true; only not required when explicitly false
  predicate isRequired() {
    not this.getValue("required").(BooleanLiteral).getBooleanValue() = false
  }
}

/**
 * An `AnnotationType` that is used to indicate a spring web request body mapping, i.e. `@RequestBody`.
 */
class SpringRequestBodyAnnotationType extends AnnotationType {
  SpringRequestBodyAnnotationType() {
    this.hasQualifiedName("org.springframework.web.bind.annotation", "RequestBody")
  }
}

class SpringRequestBodyAnnotation extends Annotation {
  SpringRequestBodyAnnotation() { this.getType() instanceof SpringRequestBodyAnnotationType }

  // Spring default for required is true; only not required when explicitly false
  predicate isRequired() {
    not this.getValue("required").(BooleanLiteral).getBooleanValue() = false
  }
}

class SwaggerApiParamAnnotationType extends AnnotationType {
  SwaggerApiParamAnnotationType() { this.hasQualifiedName("io.swagger.annotations", "ApiParam") }
}

/**
 * An `Annotation` that represents a swagger api parameter
 */
class SwaggerApiParamAnnotation extends Annotation {
  SwaggerApiParamAnnotation() { this.getType() instanceof SwaggerApiParamAnnotationType }

  string getParamName() { result = this.getStringValue("name") and result.length() > 0 }

  string getDescription() { result = this.getStringValue("value") }

  // Swagger ApiParam default for required is false
  predicate isRequired() { this.getValue("required").(BooleanLiteral).getBooleanValue() = true }

  string getDefaultValue() { result = this.getStringValue("defaultValue") }

  string getAllowableValues() { result = this.getStringValue("allowableValues") }

  string getExample() { result = this.getStringValue("example") }
}

/**
 * A parameter of a `SpringRestEndpoint`, enriched with REST binding metadata.
 */
class SpringRestParameter extends SpringRequestMappingParameter {
  /**
   * Returns the REST parameter kind based on the Spring binding annotation:
   * "query" (@RequestParam), "path" (@PathVariable), "body" (@RequestBody),
   * or "unknown" when no known binding annotation is present.
   */
  string getKind() {
    this.getAnAnnotation() instanceof SpringRequestParamAnnotation and result = "query"
    or
    this.getAnAnnotation() instanceof SpringPathVariableAnnotation and result = "path"
    or
    this.getAnAnnotation() instanceof SpringRequestBodyAnnotation and result = "body"
    or
    // No Spring binding annotation present — Spring implicitly binds simple scalars
    // from request parameters by name when compiled with -parameters
    not this.getAnAnnotation().getType().hasName(["RequestParam", "PathVariable", "RequestBody"]) and
    (
      this.getType() instanceof PrimitiveType
      or
      this.getType()
          .(RefType)
          .hasQualifiedName("java.lang",
            [
              "String", "Integer", "Long", "Boolean", "Double", "Float", "Short", "Byte",
              "Character"
            ])
    ) and
    result = "query"
    or
    not this.getAnAnnotation().getType().hasName(["RequestParam", "PathVariable", "RequestBody"]) and
    not (
      this.getType() instanceof PrimitiveType
      or
      this.getType()
          .(RefType)
          .hasQualifiedName("java.lang",
            [
              "String", "Integer", "Long", "Boolean", "Double", "Float", "Short", "Byte",
              "Character"
            ])
    ) and
    result = "unknown"
  }

  /**
   * Returns the API parameter name from the annotation value/name attribute,
   * falling back to the Java parameter name when no annotation-level name is set.
   */
  string getAPIParameterName() {
    result = this.getAnAnnotation().(SpringRequestParamAnnotation).getParamName()
    or
    result = this.getAnAnnotation().(SpringPathVariableAnnotation).getParamName()
    or
    this.getAnAnnotation().getType() instanceof SpringRequestBodyAnnotationType and result = this.getName()
    or
    // @ApiParam name is a fallback: only used when no Spring binding annotation provides a name
    not exists(SpringRequestParamAnnotation a, SpringPathVariableAnnotation b, SpringRequestBodyAnnotation c |
      a = this.getAnAnnotation().(SpringRequestParamAnnotation) or
      b = this.getAnAnnotation().(SpringPathVariableAnnotation) or
      c = this.getAnAnnotation().(SpringRequestBodyAnnotation)
    ) and
    result = this.getAnAnnotation().(SwaggerApiParamAnnotation).getParamName()
    or
    // Final fallback: Java parameter name
    not exists(
      SpringRequestParamAnnotation a, SpringPathVariableAnnotation b, SpringRequestBodyAnnotation c, SwaggerApiParamAnnotation d
    |
      a = this.getAnAnnotation().(SpringRequestParamAnnotation) or
      b = this.getAnAnnotation().(SpringPathVariableAnnotation) or
      c = this.getAnAnnotation().(SpringRequestBodyAnnotation) or
      d = this.getAnAnnotation().(SwaggerApiParamAnnotation)
    ) and
    result = this.getName()
  }

  string getDescription() {
    result = this.getAnAnnotation().(SwaggerApiParamAnnotation).getDescription()
  }

  string getDefaultValue() {
    result = this.getAnAnnotation().(SpringRequestParamAnnotation).getDefaultValue()
    or
    // @ApiParam defaultValue is a fallback when no @RequestParam is present
    not exists(this.getAnAnnotation().(SpringRequestParamAnnotation).getDefaultValue()) and
    result = this.getAnAnnotation().(SwaggerApiParamAnnotation).getDefaultValue()
  }

  predicate isRequired() {
    this.getAnAnnotation().(SpringRequestParamAnnotation).isRequired()
    or
    this.getAnAnnotation().(SpringPathVariableAnnotation).isRequired()
    or
    this.getAnAnnotation().(SpringRequestBodyAnnotation).isRequired()
    or
    this.getAnAnnotation().(SwaggerApiParamAnnotation).isRequired()
    or
    // Implicitly bound simple scalar: Spring requires it by default (no annotation = no defaultValue)
    not this.getAnAnnotation()
        .getType()
        .hasName([
            "RequestParam", "PathVariable", "RequestBody", "RequestHeader", "CookieValue",
            "RequestPart", "MatrixVariable", "ModelAttribute"
          ]) and
    (
      this.getType() instanceof PrimitiveType
      or
      this.getType()
          .(RefType)
          .hasQualifiedName("java.lang",
            [
              "String", "Integer", "Long", "Boolean", "Double", "Float", "Short", "Byte",
              "Character"
            ])
    )
  }
}

/**
 * A `SpringRestEndpoint` that extends `SpringRequestMappingMethod` to provide additional methods for extracting the full REST API path and HTTP method.
 */
class SpringRestEndpoint extends SpringRequestMappingMethod {
  // Get the path value of the controller class
  private string getControllerMappedPath() {
    result =
      this.getDeclaringType()
          .getAnAnnotation()
          .(SpringRequestMappingAnnotation)
          .getStringValue("value") and
    result.length() > 0
    or
    result =
      this.getDeclaringType()
          .getAnAnnotation()
          .(SpringRequestMappingAnnotation)
          .getStringValue("path") and
    result.length() > 0
    or
    result =
      this.getDeclaringType()
          .getAnAnnotation()
          .(SpringRequestMappingAnnotation)
          .getAStringArrayValue(["value", "path"]) and
    result.length() > 0
  }

  // Get the path value of the method
  private string getMethodMappedPath() {
    result = this.getAnAnnotation().(SpringRequestMappingAnnotation).getStringValue("value") and
    result.length() > 0
    or
    result = this.getAnAnnotation().(SpringRequestMappingAnnotation).getStringValue("path") and
    result.length() > 0
    or
    result =
      this.getAnAnnotation()
          .(SpringRequestMappingAnnotation)
          .getAStringArrayValue(["value", "path"]) and
    result.length() > 0
  }

  bindingset[path]
  private string formatMappedPath(string path) {
    path.matches("/%") and path.matches("%/") and result = path.prefix(path.length() - 1)
    or
    path.matches("/%") and not path.matches("%/") and result = path
    or
    not path.matches("/%") and path.matches("%/") and result = "/" + path.prefix(path.length() - 1)
    or
    not path.matches("/%") and not path.matches("%/") and result = "/" + path
  }

  string getMappedPath() {
    result =
      (formatMappedPath(getControllerMappedPath()) + formatMappedPath(getMethodMappedPath()))
          .replaceAll("//", "/")
  }

  /**
   * Returns the HTTP method verb: "GET", "POST", "PUT", "DELETE", "PATCH", or "ANY".
   * Handles both shorthand annotations (@GetMapping etc.) and @RequestMapping(method=...).
   */
  string getHttpMethod() {
    requestMappingAnnotation.getType().hasName("GetMapping") and result = "GET"
    or
    requestMappingAnnotation.getType().hasName("PostMapping") and result = "POST"
    or
    requestMappingAnnotation.getType().hasName("PutMapping") and result = "PUT"
    or
    requestMappingAnnotation.getType().hasName("DeleteMapping") and result = "DELETE"
    or
    requestMappingAnnotation.getType().hasName("PatchMapping") and result = "PATCH"
    or
    result =
      this.getAnAnnotation()
          .(SpringRequestMappingAnnotation)
          .getValue("method")
          .(FieldAccess)
          .getField()
          .getName()
    or
    not this.getAnAnnotation()
        .getType()
        .hasName(["GetMapping", "PostMapping", "PutMapping", "DeleteMapping", "PatchMapping"]) and
    not exists(this.getAnAnnotation().(SpringRequestMappingAnnotation).getValue("method")) and
    result = "ANY"
  }

  // Get the description of the api operation
  string getDescription() {
    result = this.getAnAnnotation().(SwaggerApiOpAnnotation).getStringValue("value") and
    result.length() > 0
    or
    result = this.getAnAnnotation().(SwaggerApiOpAnnotation).getStringValue("notes") and
    result.length() > 0
    or
    result =
      this.getAnAnnotation().(SwaggerApiOpAnnotation).getAStringArrayValue(["value", "notes"]) and
    result.length() > 0
  }
}
