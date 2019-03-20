import invoke
import terraform

ns = invoke.Collection()
ns.add_task(terraform.clean)
ns.add_task(terraform.init)
ns.add_task(terraform.validate)
ns.add_task(terraform.plan)
ns.add_task(terraform.up, default=True)
ns.add_task(terraform.down)
ns.add_task(terraform.update)
ns.configure({'iac_path': 'terraform/openstack/any/modules/environment'})
