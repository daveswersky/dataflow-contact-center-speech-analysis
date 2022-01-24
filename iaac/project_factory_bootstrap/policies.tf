module "compute-vm-external-ip-access" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0.2"
  policy_for        = "project"
  organization_id   = var.organization_id
  project_id        = module.project-factory.project_id
  constraint        = "constraints/compute.vmExternalIpAccess"
  policy_type       = "list"
  enforce           = "false"
}

module "compute-vm-required-shielded"{
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0.2"
  policy_for        = "project"
  organization_id   = var.organization_id
  project_id        = module.project-factory.project_id
  constraint        = "constraints/compute.requireShieldedVm"
  policy_type       = "boolean"
  enforce           = "false"
}

module "functions-allowed-ingress"{
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0.2"
  policy_for        = "project"
  organization_id   = var.organization_id
  project_id        = module.project-factory.project_id
  constraint        = "constraints/cloudfunctions.allowedIngressSettings"
  policy_type       = "list"
  enforce           = "false"
}

module "uniform-bucket-access"{
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 3.0.2"
  policy_for        = "project"
  organization_id   = var.organization_id
  project_id        = module.project-factory.project_id
  constraint        = "constraints/storage.uniformBucketLevelAccess"
  policy_type       = "boolean"
  enforce           = "false"
}