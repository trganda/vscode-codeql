package main

import (
	"net/http"
	"os"
	"os/exec"

	pongo2 "github.com/flosch/pongo2/v6"
)

// --- Custom filters ---

// Custom filter: input flows to a command execution sink.
func filterToCmd(in *pongo2.Value, param *pongo2.Value) (*pongo2.Value, *pongo2.Error) {
	s := in.String()
	exec.Command("sh", "-c", s).Run()
	return nil, nil
}

// Custom filter expressed as a function literal: input flows to a file path sink.
var filterToFile = func(in *pongo2.Value, param *pongo2.Value) (*pongo2.Value, *pongo2.Error) {
	os.Open(in.String())
	return nil, nil
}

// Custom filter: input flows to a request-forgery sink.
func filterToHTTP(in *pongo2.Value, param *pongo2.Value) (*pongo2.Value, *pongo2.Error) {
	http.Get(in.String())
	return nil, nil
}

// Negative case: custom filter whose input never reaches a sink.
func filterBenign(in *pongo2.Value, param *pongo2.Value) (*pongo2.Value, *pongo2.Error) {
	_ = in.Bool()
	return nil, nil
}

// --- Custom tag nodes ---

// Custom tag (v6 signature returning *pongo2.Error): field read flows to command sink.
type cmdTag struct {
	cmd string
}

func (n *cmdTag) Execute(ctx *pongo2.ExecutionContext, writer pongo2.TemplateWriter) *pongo2.Error {
	exec.Command("sh", "-c", n.cmd).Run()
	return nil
}

// Custom tag (v7 signature returning the builtin `error`): field read flows to SSRF sink.
type httpTag struct {
	url string
}

func (n *httpTag) Execute(ctx *pongo2.ExecutionContext, writer pongo2.TemplateWriter) error {
	http.Get(n.url)
	return nil
}

// Custom tag: field read flows to a file-path sink.
type fileTag struct {
	path string
}

func (n *fileTag) Execute(ctx *pongo2.ExecutionContext, writer pongo2.TemplateWriter) *pongo2.Error {
	os.Open(n.path)
	return nil
}

// Negative case: tag with a field that is never read inside Execute.
type benignTag struct {
	unused string
}

func (n *benignTag) Execute(ctx *pongo2.ExecutionContext, writer pongo2.TemplateWriter) *pongo2.Error {
	writer.WriteString("hello")
	return nil
}

// --- Filter / template registration and template execution ---

func main() {
	pongo2.RegisterFilter("toCmd", filterToCmd)
	pongo2.ReplaceFilter("toFile", filterToFile)
	pongo2.RegisterFilter("toHTTP", filterToHTTP)
	pongo2.RegisterFilter("benign", filterBenign)

	set := pongo2.NewSet("test", nil)
	set.RegisterFilter("toCmdOnSet", filterToCmd)
	set.ReplaceFilter("toHTTPOnSet", filterToHTTP)

	// Sinks for the TemplateExecuteCalls query.
	t, _ := pongo2.FromString("hello {{ name|toCmd }}")
	t.Execute(pongo2.Context{"name": "world"})

	t2, _ := set.FromString("hello {{ name }}")
	t2.ExecuteWriter(pongo2.Context{"name": "world"}, os.Stdout)
}
