//go:build dev

package main

import (
	"fmt"
	"io/fs"
	"net/http"
)

// Dummy embed.FS to satisfy the compiler (never used in dev mode)
type dummyFS struct{}

func (d dummyFS) Open(name string) (fs.File, error) {
	return nil, fs.ErrNotExist
}

var templatesFS dummyFS
var staticFS dummyFS

func setupStaticFiles() {
	// Always use filesystem in dev mode
	fmt.Println("Files are read from disk (no restart needed for static/ changes)")
	fileServer := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fileServer))
}

func useEmbedFS() bool {
	return false
}
