/**
 * Provides classes for modeling sources of template injection in
 * `github.com/flosch/pongo2` custom tags and filters.
 *
 * - For a custom **filter** (a function whose type is `pongo2.FilterFunction`),
 *   the first parameter (`in *pongo2.Value`) is treated as a remote source,
 *   because it carries data interpolated into the rendered template.
 *
 * - For a custom **tag**, a struct method whose signature matches the tag
 *   `Execute` shape (v6: `Execute(*pongo2.ExecutionContext, pongo2.TemplateWriter) *pongo2.Error`,
 *   v7: `Execute(*pongo2.ExecutionContext, pongo2.TemplateWriter) error`) is
 *   located. Any read inside that method body of a field belonging to the
 *   receiver struct is treated as a remote source, because such fields are
 *   populated by the tag parser from user-supplied template arguments.
 */

overlay[local?]
module;

import go
private import semmle.go.security.FlowSources

/** Provides classes modeling pongo2 (`github.com/flosch/pongo2/v6`). */
module Pongo2 {
  /** Gets the pongo2 package path. */
  string packagePath() { result = "github.com/flosch/pongo2/v6" }

  /**
   * A call that registers a pongo2 filter, either via the package-level
   * `pongo2.RegisterFilter` / `pongo2.ReplaceFilter` aliases or via the
   * corresponding methods on `*pongo2.TemplateSet`.
   */
  class RegisterFilterCall extends DataFlow::CallNode {
    RegisterFilterCall() {
      this.getTarget().hasQualifiedName(packagePath(), ["RegisterFilter", "ReplaceFilter"])
      or
      this.(DataFlow::MethodCallNode)
          .getTarget()
          .hasQualifiedName(packagePath(), "TemplateSet", ["RegisterFilter", "ReplaceFilter"])
    }

    /** Gets the data-flow node for the registered filter function argument. */
    DataFlow::Node getFilterFunctionSource() { result = this.getArgument(1) }
  }

  /**
   * A user-defined pongo2 filter function: a function literal or named
   * function passed as the filter implementation to `RegisterFilter` /
   * `ReplaceFilter`.
   */
  class CustomFilter extends FuncDef {
    CustomFilter() {
      exists(RegisterFilterCall reg, DataFlow::Node fn | fn = reg.getFilterFunctionSource() |
        fn = DataFlow::exprNode(this.(FuncLit))
        or
        fn = this.(FuncDecl).getFunction().getARead()
      )
    }
  }

  /**
   * The first parameter (`in *pongo2.Value`) of a custom pongo2 filter.
   * It carries the value piped into the filter expression and is therefore
   * treated as a template-injection source.
   */
  class CustomFilterInputSource extends RemoteFlowSource::Range {
    CustomFilterInputSource() {
      exists(CustomFilter f | this.asParameter().isParameterOf(f, 0))
    }
  }

  /**
   * A method whose signature matches the pongo2 tag `Execute` method:
   *
   * - v6: `Execute(*pongo2.ExecutionContext, pongo2.TemplateWriter) *pongo2.Error`
   * - v7: `Execute(*pongo2.ExecutionContext, pongo2.TemplateWriter)  error`
   *
   * The receiver type is treated as a custom tag node; built-in pongo2 tag
   * nodes are excluded.
   */
  class TagExecuteMethod extends Method {
    TagExecuteMethod() {
      this.getName() = "Execute" and
      this.getNumParameter() = 2 and
      this.getParameterType(0)
          .(PointerType)
          .getBaseType()
          .hasQualifiedName(packagePath(), "ExecutionContext") and
      this.getParameterType(1).hasQualifiedName(packagePath(), "TemplateWriter") and
      this.getNumResult() = 1 and
      this.getResultType(0) instanceof ErrorType and
      not this.getPackage().getPath() = packagePath()
    }

    /** Gets the struct type of this method's receiver (the tag-node struct). */
    StructType getReceiverStruct() {
      result = this.getReceiverBaseType().getUnderlyingType()
    }
  }

  /** A field of a struct that defines a pongo2 tag `Execute` method. */
  class TagNodeField extends Field {
    TagNodeField() { this.getDeclaringType() = any(TagExecuteMethod m).getReceiverStruct() }
  }

  /**
   * A read of a tag-node field that occurs inside the body of the tag's
   * `Execute` method. Such fields are populated by the tag parser from
   * template arguments and consumed inside `Execute`, so each read is treated
   * as a template-injection source.
   */
  class CustomTagFieldSource extends RemoteFlowSource::Range {
    CustomTagFieldSource() {
      exists(TagExecuteMethod m, DataFlow::FieldReadNode fr |
        fr = this and
        fr.getField().getDeclaringType() = m.getReceiverStruct() and
        fr.getRoot() = m.getFuncDecl()
      )
    }
  }
}
