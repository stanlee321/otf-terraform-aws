resource "local_file" "kubernetes_config" {
  content = "${aws_eks_cluster.otf.kube_config.0.raw_config}"
  filename = "kubeconfig.yaml"
}
