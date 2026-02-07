resource "github_repository" "gitops" {
  name = var.repository_name
  visibility = "private"
  auto_init = true
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository.gitops, talos_cluster_kubeconfig.this]
  path = "clusters/${var.cluster_name}"
}

