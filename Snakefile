configfile: "config.yaml"

rule webscrape:
    input: 
        "Data/{datasets}.csv"
    output: 
        "Data/{datasets}_html.csv.gz"
    script: 
        "Code/Webscrape.R"

rule cleanHTML: 
    input:
      "Data/{datasets}_html.csv.gz"
    output: 
        "Data/{datasets}_clean_html.csv.gz"
    script: 
        "Code/cleanHTML.R"
