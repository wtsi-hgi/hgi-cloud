import invoke
import terraform_tasks
ns = terraform_tasks.ns
ns.configure({'iac_path': 'terraform/modules/openstack/environments/dev'})
