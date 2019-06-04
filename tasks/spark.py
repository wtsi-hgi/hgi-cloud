import invoke
import glob
import os
import os.path
import sys

def create_terraform_vars(order):
  dirname = os.path.join('terraform', 'vars')
  added = []

  for name in order:
    os.path.exists(dirname) or os.mkdir(dirname)
    tfvars = os.path.join(dirname, '{}.tfvars'.format(name))
    if not os.path.exists(tfvars):
      with open(tfvars, 'w') as f:
        f.wite("# Automatically generated\n")
        added.append(tfvars)
    dirname = os.path.join(dirname, name)

  return added

def create_ansible_vars(order, master_role, slaves_role):
  dirname = os.path.join('ansible', 'vars')
  added = []

  for name in order:
    os.path.exists(dirname) or os.mkdir(dirname)
    yml = os.path.join(dirname, '{}.yml'.format(name))
    if not os.path.exists(yml):
      with open(yml, 'w') as f:
        f.wite("---\n# Automatically generated\n")
        added.append(yml)
    dirname = os.path.join(dirname, name)

  os.path.exists(dirname) or os.mkdir(dirname)
  for name in (master_role, slaves_role):
    yml = os.path.join(dirname, '{}.yml'.format(name))
    if not os.path.exists(yml):
      with open(yml, 'w') as f:
        f.wite("---\n# Automatically generated\n")
        added.append(yml)

  return added

@invoke.task
def init(context, master_role, slaves_role):
  order = [
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    context.config['meta']['env'],
    context.config['deployment']['name'],
    context.config['deployment']['owner']
  ]
  added = create_terraform_vars(order) + create_ansible_vars(order)

ns = invoke.Collection()
ns.add_task(init)
