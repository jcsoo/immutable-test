package main

import (
	"github.com/julienschmidt/httprouter"
	"log"
	"net/http"
)

func main() {
	router := httprouter.New()
	router.NotFound = http.FileServer(http.Dir("dist")).ServeHTTP
	log.Println("Running on :5000")
	log.Fatal(http.ListenAndServe(":5000", router))

}
