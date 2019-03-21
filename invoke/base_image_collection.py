import invoke
import packer_tasks

ns = invoke.Collection()
ns.add_task(packer_tasks.validate)
ns.add_task(packer_tasks.build, default=True)
ns.configure({'packer_template': 'base.json'})
