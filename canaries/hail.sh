#!/usr/bin/env bash

pyspark <<-CANARY
	import os
	import hail
	import pyspark
	
	APP = "hail_canary"
	
	
	if __name__ == "__main__":
	    sc = pyspark.SparkContext(appName=APP)
	    tmp_dir = os.path.join(os.environ["HAIL_HOME"], "tmp")
	    hail.init(sc=sc, app_name=APP, tmp_dir=tmp_dir, log=f"{APP}.log", append=True)
	
	    bnm = hail.balding_nichols_model(n_populations=3, n_samples=50, n_variants=100)
	    assert bnm.count() == (100, 50)
	
	    vcf = hail.import_vcf("s3a://1kg/1kg.vcf.bgz")
	    assert vcf.count() == (10961, 284)
	    print(vcf.describe())
CANARY
