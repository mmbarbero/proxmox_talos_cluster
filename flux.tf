resource "github_repository" "gitops" {
  count      = var.create_gitops_repo ? 1 : 0
  name = var.repository_name
  visibility = "private"
  auto_init = true
}

data "github_repository" "gitops" {
  full_name = "${var.github_username}/${var.repository_name}"
  depends_on = [github_repository.gitops] 
}

resource "flux_bootstrap_git" "this" {
  depends_on = [talos_cluster_kubeconfig.this]
  path = "clusters/${var.cluster_name}"
}

