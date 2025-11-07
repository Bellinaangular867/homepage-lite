//go:build !dev

package main

import (
	"embed"
	"io/fs"
	"net/http"
)

//go:embed templates/*.html
var templatesFS embed.FS

//go:embed static/*
var staticFS embed.FS

func setupStaticFiles() {
	// Try embedded files first
	staticFilesFS, fsErr := fs.Sub(staticFS, "static")
	if fsErr != nil {
		// Fallback to file system
		fileServer := http.FileServer(http.Dir("static"))
		http.Handle("/static/", http.StripPrefix("/static/", fileServer))
	} else {
		http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.FS(staticFilesFS))))
	}
}

func useEmbedFS() bool {
	return true
}
