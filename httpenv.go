package main
import (
  "encoding/json"
  "fmt"
  "net/http"
  "os"
  "strings"
)
func serve(w http.ResponseWriter, r *http.Request) {
  env := map[string]string{}
  for _, keyval := range os.Environ() {
    keyval := strings.SplitN(keyval, "=", 2)
    env[keyval[0]] = keyval[1]
  }
  bytes, err := json.Marshal(env)
  if err != nil {
    w.Write([]byte("{}"))
    return
  }
  w.Write([]byte(bytes))
}
// to start httpenv
func main() {
  fmt.Printf("Starting httpenv listening on port 8888.\n")
  http.HandleFunc("/", serve)
  if err := http.ListenAndServe(":8888", nil); err != nil {
    panic(err)
  }
}

