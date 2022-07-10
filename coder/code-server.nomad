job "code-server" {
  datacenters = ["home1"]

  type = "service"

  group "code" {
    count = 1

    network {
      mode = "host"
      port "ui" {}
      port "run" {}
    }

    task "code-server" {
      driver = "docker"

      config {
        image = "registry.home.cksuperman.com/code/server:latest"
        ports = ["ui", "run"]
        entrypoint = [
          "/usr/bin/entrypoint.sh",
          "--bind-addr",
          "0.0.0.0:${NOMAD_HOST_PORT_ui}",
          "."
        ]

        volumes = [
          "/etc/localtime:/etc/localtime:ro",
          "/var/lib/code-server:/home/coder",
        ]
      }

      vault {
        policies = ["cockroach-cloud"]
      }

      template {
        data = <<-EOH
        DATABASE_URL="postgres://{{with secret "kv/cockroachdb/cloud/access" }}{{.Data.data.user}}:{{.Data.data.password}}{{end}}@free-tier.gcp-us-central1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&sslrootcert=<your_certs_directory>/cc-ca.crt&options=--cluster=tough-lynx-961"
        EOH
        destination = "secrets/file.env"
        env         = true
      }


      service {
        name = "code"
        port = "ui"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.code_http.entrypoints=http",
          "traefik.http.routers.code_http.rule=Host(`code.home.cksuperman.com`)",
          "traefik.http.routers.code_http.middlewares=code-redirect@consulcatalog",
          "traefik.http.middlewares.code-redirect.redirectscheme.scheme=https",
          "traefik.http.middlewares.code-redirect.redirectscheme.permanent=true",
          "traefik.http.routers.code.entrypoints=https",
          "traefik.http.routers.code.rule=Host(`code.home.cksuperman.com`)",
          "traefik.http.routers.code.tls.certresolver=cloudflare",
          "traefik.http.routers.code.tls.domains[0].main=code.home.cksuperman.com",
          "wayfinder.domain=code.home.cksuperman.com",
        ]
      }

      service {
        name = "code-run"
        port = "run"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.debug_http.entrypoints=http",
          "traefik.http.routers.debug_http.rule=Host(`debug.home.cksuperman.com`)",
          "traefik.http.routers.debug_http.middlewares=debug-redirect@consulcatalog",
          "traefik.http.middlewares.debug-redirect.redirectscheme.scheme=https",
          "traefik.http.middlewares.debug-redirect.redirectscheme.permanent=true",
          "traefik.http.routers.debug.entrypoints=https",
          "traefik.http.routers.debug.rule=Host(`debug.home.cksuperman.com`)",
          "traefik.http.routers.debug.tls.certresolver=cloudflare",
          "traefik.http.routers.debug.tls.domains[0].main=debug.home.cksuperman.com",
          "wayfinder.domain=debug.home.cksuperman.com",
        ]
      }

      resources {
        cpu    = 100 # MHz
        memory = 2048 # MB
      }
    }
  }
}
