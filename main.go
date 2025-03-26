package main

import (
    "embed"
    "fmt"
    "net/http"
)

//go:embed index.html
var htmlContent embed.FS

func handler(w http.ResponseWriter, r *http.Request) {
    content, err := htmlContent.ReadFile("index.html")
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    fmt.Fprint(w, string(content))
}

func main() {
    http.HandleFunc("/", handler)
    fmt.Println("Server is running on :8080")
    http.ListenAndServe(":8080", nil)
}
