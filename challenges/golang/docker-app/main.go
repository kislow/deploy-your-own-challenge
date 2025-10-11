package main

import (
    "github.com/gin-gonic/gin"
    "os"
)

func main() {
    r := gin.Default()
    r.GET("/", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "message": os.Getenv("MESSAGE"),
        })
    })
    r.Run() // listen and serve on 0.0.0.0:8080
}
