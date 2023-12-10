--UDF to extract text from PDFs
CREATE OR REPLACE FUNCTION EXTRACT_TEXT_FROM_PDF(file string)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = 3.10
PACKAGES = ('snowflake-snowpark-python','pypdf2')
HANDLER = 'read_file'
AS
$$
from PyPDF2 import PdfFileReader
from snowflake.snowpark.files import SnowflakeFile
from io import BytesIO

def read_file(file_path):
    whole_text = ""
    with SnowflakeFile.open(file_path, 'rb') as file:
        f = BytesIO(file.readall())
        pdf_reader = PdfFileReader(f)
        whole_text = ""
        for page in pdf_reader.pages:
            whole_text += page.extract_text()
    
    return whole_text
$$

--select EXTRACT_TEXT_FROM_PDF(build_scoped_file_url(@pdf_external,'invoice1.pdf')) as pdf_text;
