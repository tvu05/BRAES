Purpose/Description of this project: 
Webscraping to expedite process of collection of literature of communal roosting behavior. First step is just running the species and seeing how many relevant articles result 
to see if this project is someting we want to move forward with. 

Three main directories to take note of:  
1) Data: This file contains the excel sheet with the core land birds. This is where we are reading the data to build the search.
2) Outputs: This file contains a csv file as an excel sheet which contains the species in one column and the number of articles per species.
3) Scripts: This file contains all the R scripts where we have been writing code. There are a few scripts in there where they have been updated each time we work on them. 

## Scopus

IMPORTANT: Never publicly release your API Key, this includes uploading it to this GitHub repo; this is easy to accidentally do if you include it in a script than push that script to the repository.

* Go to [https://dev.elsevier.com/](https://dev.elsevier.com/) and select 'I want an API Key'. You should be promptd to log in with your CWL, if you're on a UBC network, or simply create an account with your @ubc email address.
* You'll want to use the [Scopus Search API](https://dev.elsevier.com/documentation/ScopusSearchAPI.wadl)
* And refer to [this documentation](https://dev.elsevier.com/sc_search_tips.html) for building the search.
* And [this documentation](https://dev.elsevier.com/api_key_settings.html), under the header 'Scopus APIs', for rate throttling (9 per second, daily max of 20 000)
* Check out the GUI for [Scopus](https://resources.library.ubc.ca/page.php?details=scopus&id=2753)

**Sample Query**

You can plug this into your web browser:

```{r}
base_url <- "https://api.elsevier.com/content/search/scopus?"
query <- "TITLE-ABS-KEY('Accipiter%20badius'%20AND%20(roost%20OR%20roosting%20OR%20communally%20OR%20communal))"
apiKey <- "YOUR API KEY"

search <- paste0(base_url, "query=", query, "&apiKey=", apiKey)
search
```

You'll see the results returned at the top. You can then use the same packages/functions as in OpenAlex, to build this query in R, and extract the relevant data.

## Wikipedia

I have uploaded a sample Python notebook `wikipedia-scrape.ipynb` that loads the requests module (for retrieving html requests) and BeautifulSoup (for parsing html), has one query and stores the output in a BeautifulSoup object. You can the refer to the [BeautifulSoup documentation](https://beautiful-soup-4.readthedocs.io/en/latest/) for navigating the page. This is often helped by starting with you web browsers 'inspect' feature to figure out where the data that you want is located.

Once you're comfortable with one page, and know what you need to identify before deciding that it's to be included, you can start building some loops.