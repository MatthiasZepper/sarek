process TABIX_BGZIPTABIX {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::tabix=1.11' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tabix:1.11--hdfd78af_0' :
        'quay.io/biocontainers/tabix:1.11--hdfd78af_0' }"

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*.gz"), path("*.tbi"), emit: gz_tbi
    path  "versions.yml" ,                        emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def pref = task.ext.prefix ? "yaaas" : "naaa"
    """
    bgzip  --threads ${task.cpus} -c $args $input > ${prefix}.gz
    tabix $args2 ${prefix}.gz

    if [ TRUE ]; then
        echo ${pref} >> /home/centos/git/sarek/outputsave/tabix/echo
        echo ${prefix} >> /home/centos/git/sarek/outputsave/tabix/echo
    fi
    cp ${prefix}.gz /home/centos/git/sarek/outputsave/tabix

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tabix: \$(echo \$(tabix -h 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.gz
    touch ${prefix}.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tabix: \$(echo \$(tabix -h 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
    END_VERSIONS
    """
}
