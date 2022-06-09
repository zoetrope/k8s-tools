//go:build tools
// +build tools

package k8s_tools

import (
	// These are to declare dependency on tools
	_ "github.com/go-delve/delve/cmd/dlv"
)
