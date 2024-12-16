import pandas as pd 

metadata = {}

new_datasets = [
    "1098-5530", #jb
    "1935-7885", #jmbe
    "2150-7511", #mbio
    "2165-0497", #mspec
    "2379-5042", #msph
    "2379-5077", #msys
    "2576-098X", #mra
    "0095-1137", #jcb
    "1098-5336", #aem
    "1098-5514", #jv
    "1098-5522", #i&i
    "1098-6596", #aac
]

new_datasets = {
    "1098-5530" : "Data/1098-5530_metadata.RDS", #jb
    "1935-7885" : "Data/1935-7885_metadata.RDS", #jmbe
    "2150-7511" : "Data/2150-7511_metadata.RDS", #mbio
    "2165-0497" : "Data/2165-0497_metadata.RDS", #mspec
    "2379-5042" : "Data/2379-5042_metadata.RDS", #msph
    "2379-5077" : "Data/2379-5077_metadata.RDS", #msys
    "2576-098X" : "Data/2576-098X_metadata.RDS", #mra
    "0095-1137" : "Data/0095-1137_metadata.RDS", #jcb
    "1098-5336" : "Data/1098-5336_metadata.RDS", #aem
    "1098-5514" : "Data/1098-5514_metadata.RDS", #jv
    "1098-5522" : "Data/1098-5522_metadata.RDS", #i&i
    "1098-6596" : "Data/1098-6596_metadata.RDS", #aac
}


#not these rn 
# for datasets in new_datasets.keys(): 
#     metadata[datasets] = pd.read_csv(f"Data/papers/{datasets}.csv")["html_filename"]
   
# for datasets in new_datasets.keys(): 
#     # metadata[datasets] = 
#     print(f"Data/papers/{datasets}.csv".strip())


#redundant from above
metadata = {}

for datasets in new_datasets.keys(): 
    metadata[datasets] = pd.read_csv(f"Data/papers/{datasets}.csv".replace(" ", ""), sep = ",", low_memory = False)["unique_id"]

# html_filename =  lambda wildcards: metadata[wildcards.new_datasets]

list_inputs_all = [
    f"{html_filename}.html".replace(" ", "")
    for html_filename
    in metadata.items()
]

listOfHTMLs = {}
for key in metadata:
    print(len(metadata[key]))
    values = []
    for value in metadata[key]:
        values.append(value)
    listOfHTMLs[key] = values

#print statments not needed
print(listOfHTMLs)

print(list_inputs_all)

len(list_inputs_all)


# 20241212 - looking at trying to generate the htmls
htmls = pd.read_csv("Data/papers/html_table.csv.gz", names = ["html", "predicted"])
html_lookup = dict(zip(htmls["html"], htmls["predicted"]))

html_lookup.items()

html_lookup["Data/html/10.1128_mra.00373-24.csv"]
