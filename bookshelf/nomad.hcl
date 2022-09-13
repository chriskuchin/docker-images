job "bookshelf" {
  datacenters = ["home1"]

  type = "service"

  group "bookshelf" {
    count = 1

    network {
      port "http" {}
    }

    task "bookshelf" {
      driver = "docker"

      config {
        image = "altescy/bookshelf:latest"
        ports =["http"]

        entrypoint = []
        volumes = [
          "/etc/localtime:/etc/localtime:ro",
          "/var/lib/bookshelf:/data"
        ]
      }

      vault {
        policies = ["cloudflare-r2"]
        change_mode = "restart"
      }

      template {
        data = <<-EOH
        {{with secret "kv/cloudflare/r2/bookshelf" }}
        BOOKSHELF_DB_URL=sqlite3:///data/bookshelf.db
        BOOKSHELF_STORAGE_URL=s3://{{.Data.data.bucket}}
        BOOKSHELF_AWS_ACCESS_KEY_ID={{.Data.data.access_key}}
        BOOKSHELF_AWS_SECRET_ACCESS_KEY={{.Data.data.secret_key}}
        BOOKSHELF_AWS_S3_REGION=auto
        BOOKSHELF_AWS_S3_ENDPOINT_URL={{.Data.data.endpoint}}
        {{end}}
        BOOKSHELF_PORT={{ env "NOMAD_PORT_http" }}
        EOH
        destination = "secrets/r2.env"
        env = true
      }

      service {
        name = "bookshelf"
        port = "http"
        tags = []
      }

      resources {
        cpu = 100
        memory = 256
      }
    }
  }

}