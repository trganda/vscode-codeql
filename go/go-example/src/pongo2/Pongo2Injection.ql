/**
 * @id trganda/go-example/pongo2-injection
 * @name Untrusted pongo2 input flowing to a dangerous sink
 * @description Tracks taint from custom pongo2 tag-node fields and custom
 *              pongo2 filter inputs to sinks that may cause command
 *              execution, server-side request forgery, or arbitrary file
 *              reading.
 * @kind path-problem
 * @precision medium
 * @problem.severity warning
 * @tags go-example security
 */

import go
import semmle.go.dataflow.TaintTracking
import semmle.go.security.CommandInjectionCustomizations
import semmle.go.security.RequestForgeryCustomizations
import semmle.go.security.TaintedPathCustomizations
import Pongo2

module PongoInjectionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source instanceof Pongo2::CustomTagFieldSource or
    source instanceof Pongo2::CustomFilterInputSource
  }

  predicate isSink(DataFlow::Node sink) {
    sink instanceof CommandInjection::Sink or
    sink instanceof RequestForgery::Sink or
    sink instanceof TaintedPath::Sink
  }
}

module PongoInjectionFlow = TaintTracking::Global<PongoInjectionConfig>;

import PongoInjectionFlow::PathGraph

string sinkKind(DataFlow::Node sink) {
  sink instanceof CommandInjection::Sink and result = "command execution"
  or
  sink instanceof RequestForgery::Sink and result = "SSRF"
  or
  sink instanceof TaintedPath::Sink and result = "file path"
}

string sourceKind(DataFlow::Node source) {
  source instanceof Pongo2::CustomTagFieldSource and result = "custom pongo2 tag-node field"
  or
  source instanceof Pongo2::CustomFilterInputSource and result = "custom pongo2 filter input"
}

from PongoInjectionFlow::PathNode source, PongoInjectionFlow::PathNode sink
where PongoInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Untrusted " + sourceKind(source.getNode()) + " flows to a " + sinkKind(sink.getNode()) + " sink."
