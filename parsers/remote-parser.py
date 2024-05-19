from llmsherpa.readers import LayoutPDFReader
import regex as re
import json


if __name__=='__main__':
    # Create a reader object
    reader = LayoutPDFReader("https://readers.llmsherpa.com/api/document/developer/parseDocument?renderFormat=all")
    doc = reader.read_pdf('https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-160v2r1.pdf')
    doc_json = doc.json
    
    with open('nist.json', 'w') as f:
        json.dump(doc_json, f, indent=4)
    f.close()
    