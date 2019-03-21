import invoke
import terraform_tasks

ns = invoke.Collection()
ns.add_task(terraform_tasks.clean)
ns.add_task(terraform_tasks.init)
ns.add_task(terraform_tasks.validate)
ns.add_task(terraform_tasks.plan)
ns.add_task(terraform_tasks.up, default=True)
ns.add_task(terraform_tasks.down)
ns.add_task(terraform_tasks.update)
ns.configure({'iac_path': 'terraform/openstack/modules/infrastructure'})
