FROM golang:1.27-alpine AS builder

# All following commands run inside /src (created automatically).
WORKDIR /src
COPY httpenv.go .

# CGO_ENABLED=0 → a fully static binary that needs no C libraries at runtime.
# -ldflags="-s -w" → strip debug info, making the binary smaller.
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/httpenv httpenv.go

# ---- Stage 2: the small image we actually ship -------------------------------
# Only this stage ends up in the final image. The Go compiler (~300 MB) stays behind.
FROM alpine:3.24

RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv

# Copy ONLY the compiled program from the builder stage, by name.
COPY --from=builder --chown=httpenv:httpenv /out/httpenv /httpenv

# Run as the unprivileged user (numeric, so any system can verify it's not root).
USER 1000:1000

# Documentation only: says which port the app listens on. It doesn't open anything.
EXPOSE 8888
CMD ["/httpenv"]