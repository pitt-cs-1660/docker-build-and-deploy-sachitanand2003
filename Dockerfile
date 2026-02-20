# ── Build Stage ──────────────────────────────────────────────────────────────
FROM golang:1.23 AS builder

WORKDIR /app

# Copy dependency manifest and source
COPY go.mod ./
COPY main.go ./
COPY templates ./templates

# Compile a fully static binary (no CGo, no external C deps)
RUN CGO_ENABLED=0 go build -o binarynames .

# ── Final Stage ──────────────────────────────────────────────────────────────
FROM scratch

WORKDIR /app

# Pull only what we need from the build stage
COPY --from=builder /app/binarynames .
COPY --from=builder /app/templates ./templates

# Start the server
CMD ["/app/binarynames"]