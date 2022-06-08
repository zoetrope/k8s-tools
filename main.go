package main

import (
	"flag"
	"io"
	"log"
	"net/http"
)

var flagListen = flag.String("listen", ":8000", "Listen address and port")

func main() {
	flag.Parse()
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		io.WriteString(w, "Hello, World!")
	})
	err := http.ListenAndServe(*flagListen, nil)
	if err != nil {
		log.Fatal(err)
	}
}
