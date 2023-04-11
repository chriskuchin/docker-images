job "stump" {
  datacenters = ["home1"]

  type = "service"

  group "stump" {
    count = 1

    network {
      port "http" {
        static = 6969
      }
    }

    task "stump" {
      driver = "docker"

      config {
        image = "aaronleopold/stump:nightly"
        ports =["http"]

        entrypoint = []
        volumes = [
          "/var/lib/stump:/data",
          "/opt/stump/config:/config"
        ]
      }

      template {
        data = <<-EOH
        PUID=1000
        PGID=1000
        EOH
        destination = "local/config.env"
        env = true
      }

      service {
        name = "stump"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.stump_http.entrypoints=http",
          "traefik.http.routers.stump_http.rule=Host(`stump.home.cksuperman.com`)",
          "traefik.http.routers.stump_http.middlewares=stump-redirect@consulcatalog",
          "traefik.http.middlewares.stump-redirect.redirectscheme.scheme=https",
          "traefik.http.middlewares.stump-redirect.redirectscheme.permanent=true",
          "traefik.http.routers.stump.entrypoints=https",
          "traefik.http.routers.stump.rule=Host(`stump.home.cksuperman.com`)",
          "traefik.http.routers.stump.tls.certresolver=cloudflare",
          "traefik.http.routers.stump.tls.domains[0].main=stump.home.cksuperman.com",
          "wayfinder.domain=stump.home.cksuperman.com",
        ]
      }

      resources {
        cpu = 100
        memory = 256
      }
    }
  }

}