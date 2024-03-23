from llmsherpa.readers import LayoutPDFReader
import regex as re

def reference_extraction(doc):
    references = {}
    
    for section in doc.sections():
        if (section.title == 'REFERENCES' or section.title == 'References' or 
            section.title == 'Bibliography' or section.title == 'BIBLIOGRAPHY'):
            
            for i,par in enumerate(section.chunks()):
                text = par.to_text()
                ref_num = re.findall(r"\[\d+\]", text)
                
                if(ref_num == []):
                    references[f"[{str(i)}]"] = text
                elif(len(ref_num) == 1):
                    references[ref_num[0]] = text
                else: #parsing multiple references inside the paragraph
                    ref_num = [m.replace("[", "\[").replace("]","\]") for m in ref_num]
                    blocks = []
                    refs = "|".join(ref_num)
                    print(refs)
                    print(re.split(refs, text))
                    exit()
        
    return references


if __name__=='__main__':
    # Create a reader object
    reader = LayoutPDFReader("https://readers.llmsherpa.com/api/document/developer/parseDocument?renderFormat=all")
    doc = reader.read_pdf('tests/shellgpt.pdf')
    reference_extraction(doc)
    
    
    
    