Create or replace table parsed_pdf as
select
    relative_path
    , file_url
    , EXTRACT_TEXT_FROM_PDF(build_scoped_file_url(@pdf_external, relative_path)) as parsed_text
from directory(@pdf_external);

--SELECT * FROM DEV_DB.DEV_SCHEMA.PARSED_PDF;