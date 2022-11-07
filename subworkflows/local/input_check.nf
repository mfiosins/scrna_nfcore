//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'
include { CREATE_CSV_FROM_FOLDER } from '../../modules/local/create_csv_from_folder'
workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv
    folder // path :path/to/folder_with_fastqc



    main:
    print("Starting input check")
    if(samplesheet){
        print("Samplesheet check")    
        SAMPLESHEET_CHECK ( samplesheet )
            .csv
            .splitCsv ( header:true, sep:',' )
            .map { create_fastq_channel(it) }
            .groupTuple(by: [0]) // group replicate files together, modifies channel to [ val(meta), [ [reads_rep1], [reads_repN] ] ]
            .map { meta, reads -> [ meta, reads.flatten() ] } // needs to flatten due to last "groupTuple", so we now have reads as a single array as expected by nf-core modules: [ val(meta), [ reads ] ]
            .set { reads }
    }else{
        print("Create csv from folder")
        print(folder)
        CREATE_CSV_FROM_FOLDER (folder)
            .csv
            .splitCsv ( header:true, sep:',' )
            .map { create_fastq_channel(it) }
            .groupTuple(by: [0]) // group replicate files together, modifies channel to [ val(meta), [ [reads_rep1], [reads_repN] ] ]
            .map { meta, reads -> [ meta, reads.flatten() ] } // needs to flatten due to last "groupTuple", so we now have reads as a single array as expected by nf-core modules: [
            .set { reads }
    }
    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
    versions = samplesheet ? SAMPLESHEET_CHECK.out.versions : CREATE_CSV_FROM_FOLDER.out.versions // channel: [ versions.yml ]
}


// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample
    meta.single_end = row.single_end.toBoolean()

    // add path(s) of the fastq file(s) to the meta map
    def fastq_meta = []
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }
    if (meta.single_end) {
        fastq_meta = [ meta, [ file(row.fastq_1) ] ]
    } else {
        if (!file(row.fastq_2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
        }
        fastq_meta = [ meta, [ file(row.fastq_1), file(row.fastq_2) ] ]
    }
    return fastq_meta
}