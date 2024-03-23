import json 
import pandas as pd


with open('nist.json', 'r') as f:
    data = json.load(f)
f.close()

for elem in data:
    if(elem['tag'] == 'table'):
        df = pd.json_normalize(elem['table_rows'])
        print(len(elem['table_rows']))
        excel_file_path = 'output.xlsx'
        df.to_excel(excel_file_path, index=False)
        break