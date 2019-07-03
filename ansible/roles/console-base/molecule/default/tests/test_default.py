import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_ipython(host):
    # ipython <<IPYTHON
    # import hail as hl
    # mt = hl.balding_nichols_model(n_populations=3, n_samples=50,
    #                               n_variants=100)
    # mt.count()
    # IPYTHON
    assert True


def test_pyspark(host):
    # pyspark ${PYSPARK_ARGS} <<PYSPARK
    # import hail as hl
    # hl.init(sc)
    # mt = hl.balding_nichols_model(n_populations=3, n_samples=50,
    #                               n_variants=100)
    # mt.count()
    # PYSPARK
    assert True
