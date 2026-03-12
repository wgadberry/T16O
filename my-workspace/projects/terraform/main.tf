###############################################################################
# Root Module - Wires all child modules together
###############################################################################

module "vpc" {
  source = "./modules/vpc"
}

module "compute" {
  source = "./modules/compute"

  subnet_id              = module.vpc.subnet_id_us_east_1a
  availability_zone      = module.vpc.subnet_az_us_east_1a
  sg_velintra_id         = module.vpc.sg_velintra_id
  sg_t16o_v1_services_id = module.vpc.sg_t16o_v1_services_id
}

module "networking" {
  source = "./modules/networking"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
}

module "api_gateway" {
  source = "./modules/api_gateway"
}

module "dns" {
  source = "./modules/dns"

  nlb_dns_name = module.networking.nlb_dns_name
  nlb_zone_id  = module.networking.nlb_zone_id
}

module "storage" {
  source = "./modules/storage"
}

module "iam" {
  source = "./modules/iam"
}

module "monitoring" {
  source = "./modules/monitoring"
}
