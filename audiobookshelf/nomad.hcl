job "audiocd bookshelf" {
  datacenters = ["home1"]

  type = "service"

  group "audiobookshelf" {
    count = 1

    network {
      port "http" {}
    }

    task "audiobookshelf" {
      driver = "docker"

      config {
        image = "ghcr.io/advplyr/audiobookshelf:latest"
        ports = ["http"]

        entrypoint = []
        volumes = [
          "/etc/localtime:/etc/localtime:ro",
          "/var/lib/audiobookshelf/config:/config",
          "/var/lib/audiobookshelf/metadata:/metadata",
          "/var/lib/audiobookshelf/audiobooks:/audiobooks",
          "/var/lib/audiobookshelf/podcasts:/podcasts"
        ]
      }

      template {
        data        = <<-EOH
        PORT={{ env "NOMAD_PORT_http" }}
        EOH
        destination = "local/config.env"
        env         = true
      }

      service {
        name = "bookshelf"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.audiobookshelf_http.entrypoints=http",
          "traefik.http.routers.audiobookshelf_http.rule=Host(`audiobookshelf.home.cksuperman.com`)",
          "traefik.http.routers.audiobookshelf_http.middlewares=audiobookshelf-redirect@consulcatalog",
          "traefik.http.middlewares.audiobookshelf-redirect.redirectscheme.scheme=https",
          "traefik.http.middlewares.audiobookshelf-redirect.redirectscheme.permanent=true",
          "traefik.http.routers.audiobookshelf.entrypoints=https",
          "traefik.http.routers.audiobookshelf.rule=Host(`audiobookshelf.home.cksuperman.com`)",
          "traefik.http.routers.audiobookshelf.tls.certresolver=cloudflare",
          "traefik.http.routers.audiobookshelf.tls.domains[0].main=audiobookshelf.home.cksuperman.com",
          "wayfinder.domain=audiobookshelf.home.cksuperman.com",
        ]
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }

}