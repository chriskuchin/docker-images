job "kavita" {
  datacenters = ["home1"]

  type = "service"

  group "kavita" {
    count = 1

    network {
      port "http" {
        to = "5000"
      }
    }

    task "kavita" {
      driver = "docker"

      config {
        image = "kizaing/kavita:0.7.1.3"
        ports =["http"]

        entrypoint = []
        volumes = [
          "/etc/localtime:/etc/localtime:ro",
          "/kavita/data/directory:/kavita/config",
          "/opt/kavita/media:/manga"
        ]
      }


      service {
        name = "kavita"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.kavita_http.entrypoints=http",
          "traefik.http.routers.kavita_http.rule=Host(`kavita.home.cksuperman.com`)",
          "traefik.http.routers.kavita_http.middlewares=kavita-redirect@consulcatalog",
          "traefik.http.middlewares.kavita-redirect.redirectscheme.scheme=https",
          "traefik.http.middlewares.kavita-redirect.redirectscheme.permanent=true",
          "traefik.http.routers.kavita.entrypoints=https",
          "traefik.http.routers.kavita.rule=Host(`kavita.home.cksuperman.com`)",
          "traefik.http.routers.kavita.tls.certresolver=cloudflare",
          "traefik.http.routers.kavita.tls.domains[0].main=kavita.home.cksuperman.com",
          "wayfinder.domain=kavita.home.cksuperman.com",
        ]
      }

      resources {
        cpu = 100
        memory = 256
      }
    }
  }

}