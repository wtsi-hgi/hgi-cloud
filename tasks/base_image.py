import invoke
import packer

ns = invoke.Collection()
ns.add_task(packer.validate)
ns.add_task(packer.build, default=True)
ns.configure({'packer_template': 'base.json'})
