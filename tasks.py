from invoke import task, Collection

import terraform.tasks

@task
def default(context):
  print('Excelsior!')

ns = Collection()
ns.add_collection(Collection.from_module(terraform.tasks, name='terraform'))
