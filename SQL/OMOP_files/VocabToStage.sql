-- load vocabulary files to OMOP_VOCABULARIES internal stage

put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/*.csv' @OMOP_VOCABULARIES;