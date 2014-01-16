from urllib import quote
import urllib2
import json


def translateText(source_text, source_lang, dest_lang):
    source_text = quote(source_text)

    #Got this API_KEY on registering for billing.
    API_KEY = "AIzaSyBJb4Rn0CTG8mlxRphk1S6VdQh6q3L9sJc"

    hdr = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11'
               }
    link = "https://www.googleapis.com/language/translate/v2?key=" + API_KEY + "&source=" + source_lang + "&target=" + dest_lang + "&q=" + source_text
    req = urllib2.Request(link, headers=hdr)
    response = urllib2.urlopen(req)
    text = response.read()
    json_obj = json.loads(text)
    return json_obj.get('data').get('translations')[0].get('translatedText')
