

# HINTS & GUIDANCE

## 💡 Hint 1: Base Image Selection

For Go applications, you have several base image options:
- **`golang:1.22-alpine`** - Lightweight, includes Go toolchain (~300MB)
- **`alpine:latest`** - Ultra-light, but requires pre-built binary (~5MB)
- **Multi-stage approach** - Build with golang image, run with alpine (optimal)

**Tip:** Alpine-based images are smaller but may require additional packages like `ca-certificates` for HTTPS requests.

## 💡 Hint 2: Working Directory Structure

A typical Dockerfile structure for Go apps:
```dockerfile
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o app-name .
```

**Why this order?** Docker caches layers. By copying `go.mod` first, dependency downloads are cached unless dependencies change.

## 💡 Hint 3: Multi-Stage Build Pattern

Multi-stage builds dramatically reduce image size:
```dockerfile
# Stage 1: Build
FROM golang:1.22-alpine AS builder
# ... build steps ...

# Stage 2: Run
FROM alpine:latest
COPY --from=builder /app/binary /app/binary
```

**Result:** Final image contains only the binary and runtime dependencies, not the entire Go toolchain.

## 💡 Hint 4: Common Gotchas

**Problem:** Binary won't execute in alpine
- **Solution:** Build with `CGO_ENABLED=0` for static linking
- **Command:** `CGO_ENABLED=0 go build -o app .`

**Problem:** Port not accessible
- **Solution:** Ensure `EXPOSE 8080` is in Dockerfile AND `-p 8080:8080` is in run command

**Problem:** Environment variable not working
- **Solution:** Use `os.Getenv("MESSAGE")` in Go code and pass `-e MESSAGE="..."` to docker run

💡 Hint 5: .dockerignore Examples

Create a `.dockerignore` file to exclude unnecessary files:
```
.git
.gitignore
*.md
Dockerfile
.dockerignore
bin/
*.exe
coverage.*
```

**Why?** Reduces build context size and speeds up builds.

### Hint 6: Health Check Implementation

Add a health check to your Dockerfile:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1
```

**Note:** You may need to install `wget` or `curl` in alpine with:
```dockerfile
RUN apk add --no-cache wget
```

## 💡 Hint 7: Debugging Tips

If your container fails:
1. **Check logs:** `docker logs <container-id>`
2. **Interactive shell:** `docker run -it go-app sh`
3. **Inspect image:** `docker history go-app` (see layer sizes)
4. **Test locally:** Ensure `go run main.go` works first

**Common error:** "exec format error" means wrong architecture or static linking issue.

💡 Hint 8: Optimization Checklist

To achieve <50MB image size:
- ✅ Use multi-stage build
- ✅ Use `alpine:latest` as final stage
- ✅ Build static binary with `CGO_ENABLED=0`
- ✅ Use `go build -ldflags="-s -w"` to strip debug info
- ✅ Only copy the binary, not source code

**Example build command:**
```bash
CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o app .
```
