# include the config file
configfile: "config.yaml"

# define a function to return target files based on config settings
def run_all_input(wildcards):

    run_all_files = []
    # # if mapping is set to true add fragment calculation metrics
    # if config['modules']['mapping']:
    run_all_files.append("01.vcf_merge/{id}.samples.filtered.parsed.txt".format(id = config['samples']['id']))
    run_all_files.append("03.annotation/{id}.samples.filtered.annotated.vcf.gz".format(id = config['samples']['id']))
    return run_all_files


# rule run all, the files above are the targets for snakemake
rule run_all:
    input:
        run_all_input
smk_path = config['params']['smk_path']
include: smk_path+"/mtDNA_mitoquest.smk"
