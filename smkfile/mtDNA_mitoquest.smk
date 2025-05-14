
# Rule for SNV calling using mitoquest
rule raw_SNV_calling:
    input:
        raw_ref_fa = config['params']['raw_ref_fa'],
        raw_bam_list = config['samples']['raw_bam_list']
    output:
        "mt_raw/{id}.non_control.vcf.gz".format(id = config['samples']['id']),
    threads:
        config['threads']
    params:
        mitoquest = config['params']['mitoquest'],
        mapQ = config['params']['mapQ'],
        baseQ = config['params']['baseQ']
    shell:
        "{params.mitoquest} caller -t {threads} -f {input.raw_ref_fa} -r chrM:576-16024 --pairs-map-only -q {params.mapQ} -Q {params.baseQ} -b {input.raw_bam_list} -o {output}"

# Rule for SNV calling using mitoquest
rule shifted_SNV_calling:
    input:
        shifted_ref_fa = config['params']['shifted_ref_fa'],
        shifted_bam_list = config['samples']['shifted_bam_list']
    output:
        "mt_shifted/{id}.control.vcf.gz".format(id = config['samples']['id'])
    threads:
        config['threads']
    params:
        mitoquest = config['params']['mitoquest'],
        mapQ = config['params']['mapQ'],
        baseQ = config['params']['baseQ']
    shell:
        "{params.mitoquest} caller -t {threads} -f {input.shifted_ref_fa} -r chrM:8024-9145 --pairs-map-only -q {params.mapQ} -Q {params.baseQ} -b {input.shifted_bam_list} -o {output}"


# generate raw bam 
rule merge_VCF:
    input:
        control_vcf = "mt_shifted/{id}.control.vcf.gz",
        non_control_vcf = "mt_raw/{id}.non_control.vcf.gz"
    output:
        "01.vcf_merge/{id}.samples.vcf"
    params:
        scripts_dir = config['params']['scripts_dir'],
        python = config['params']['python'],
        ref_dir = config['params']['ref_dir']
    shell:
        """
        {params.python} {params.scripts_dir}/merge_cr_ncr_vcf.py -v1 {input.non_control_vcf} \
                    -r1 {params.ref_dir}/Homo_sapiens.GRCh38.chrM_rCRS.non_control_region.interval_list \
                    -v2 {input.control_vcf} \
                    -r2 {params.ref_dir}/Homo_sapiens.GRCh38.chrM_rCRS.control_region.shifted_by_8000_bp.interval_list \
                    -o {output}
        """

# filter reads with mapping quality < INT and unmapped
rule filter_merged_VCF:
    input:
        "01.vcf_merge/{id}.samples.vcf"
    output:
        filtered_vcf = "01.vcf_merge/{id}.samples.filtered.vcf.gz",
        parsed_txt = "01.vcf_merge/{id}.samples.filtered.parsed.txt"
    params:
        prefix = "01.vcf_merge/{id}.samples.filtered.vcf",
        scripts_dir = config['params']['scripts_dir'],
        python = config['params']['python']
    shell:
        """
        {params.python} {params.scripts_dir}/filter_mergedVCF.py -i {input} -q 20 -f 0 -d 5 -o {params.prefix} && \
        {params.python} {params.scripts_dir}/parse_vcf.py {params.prefix}.gz {output.parsed_txt}
        """

# sort hq bam
rule annotate_vcf:
    input:
        "01.vcf_merge/{id}.samples.filtered.vcf.gz"
    output:
        txt = "03.annotation/{id}.samples.filtered.annotated.txt",
        vcf = "03.annotation/{id}.samples.filtered.annotated.vcf.gz"
    params:
        scripts_dir = config['params']['scripts_dir'],
        python = config['params']['python'],
        prefix = "03.annotation/{id}.samples.filtered.annotated.vcf",
        annotation_dir = config['params']['annotation_dir']
    shell:
        """
        {params.python} {params.scripts_dir}/mito_annotate.py \
            -i {input} \
            -d {params.annotation_dir} \
            -o {output.txt} \
            -v {output.vcf}
        """
        