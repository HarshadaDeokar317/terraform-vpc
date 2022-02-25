#kubernetes provider to check kube config file validation
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

#App Deployment and service 

resource "kubernetes_pod" "flask" {
  metadata {
    name = "flask-example"
    labels = {
      App = "flask"

    }
    
  }

  spec {
    container {
  #    image = "nginx:1.15.2"
      image = "harshadadeokar/python-flask-sqlite-app1:1.1"
      name  = "example"

      port {
        container_port = 7070
      }
    }
  }
}


resource "kubernetes_service" "flask" {
  metadata {
    name = "flask-example"
  }
  spec {
    selector = {
      App = "${kubernetes_pod.flask.metadata.0.labels.App}"
    }
    port {
      port = 7070
      target_port = 7070
    }

    type = "LoadBalancer"
  }
}

