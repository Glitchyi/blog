package main

import (
    "embed"
    "fmt"
    "net/http"
)

//go:embed public/*
//go:embed content/*
//go:embed index.html
var static embed.FS

func main() {
    http.Handle("/", http.FileServer(http.FS(static)))
    fmt.Println("Server is running on :8080")
    http.ListenAndServe(":8080", nil)
}
