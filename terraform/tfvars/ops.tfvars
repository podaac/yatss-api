stage = "ops"

load_balancer_name    = "hydrocron-api-alb"
load_balancer_sg_name = "svc-hydrocron-api-ops-lb-sg"

l2ss_base_url             = "https://podaac-tools.jpl.nasa.gov/l2ss-services/l2ss"
earth_data_login_base_url = "https://urs.earthdata.nasa.gov"
harmony_base_url          = "https://harmony.earthdata.nasa.gov"
LIST_OF_AUTHORIZED_CORS_REQUESTER_ORIGINS = "https://podaac-tools.jpl.nasa.gov, https://hydrocron.podaac.earthdatacloud.nasa.gov, http://localhost:8901"
