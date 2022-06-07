//go:build tools
// +build tools

package k8s_tools

import (
	// These are to declare dependency on tools
	_ "github.com/google/go-jsonnet/cmd/jsonnet"
	_ "github.com/google/go-jsonnet/cmd/jsonnet-lint"
	_ "github.com/google/go-jsonnet/cmd/jsonnetfmt"
)
