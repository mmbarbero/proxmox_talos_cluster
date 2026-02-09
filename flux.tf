data "github_repository" "gitops" {
  full_name = "${var.github_username}/${var.repository_name}"
}

resource "flux_bootstrap_git" "this" {
  depends_on = [data.github_repository.gitops, talos_cluster_kubeconfig.this]
  path = "clusters/${var.cluster_name}"
}
