"""
Dependencies:
apt-get install python-dev libxml2-dev libxslt-dev liblz-dev build-dep python-lxml
pip install lxml python-dateutil
"""
import requests
import json
import lxml.html as lhtml
import contextlib
import base64, urllib2, urllib
import dateutil.parser

def remove_old_annotations(
        SERVER_URL = "http://54.83.200.115/",
        AUTH = None,
    ):
    if AUTH is None: AUTH=(raw_input("username: "), raw_input("password: "))
    r = requests.request("GET", SERVER_URL + "annotator/search?client=import-script-0.0.0", auth=AUTH)
    annotations = json.loads(r.text)
    
    for annotation in annotations.get('rows'):
        print "http://54.83.200.115/annotator/annotations/" + annotation.get("id")
        r = requests.request("DELETE", "http://54.83.200.115/annotator/annotations/" + annotation.get("id"), auth=AUTH)
        print r

def token_with_offset_gen(text):
    """
    Parse the text into a series of tokens of the form
    ("token text", (start_offset, end_offset))
    """
    token_start = None
    for offset in xrange(len(text)):
        if token_start is None:
            token_start = offset
        elif text[offset:offset+1] == ' ':
            yield (text[token_start:offset], (token_start, offset))
            token_start = None

class TaggedToken:
    def __init__(self, tag, token):
        self.tag = tag
        self.token = token
        
def merge_tokens(tokens):
    """
    Combine two adjacent tokens with offsets
    into one token with an offset that spans them both
    """
    return (' '.join(tokens_to_string(tokens)), (tokens[0][1][0], tokens[-1][1][1]))

def tokens_to_string(tokens, offset=0):
    """
    Convert an array of tokens to a space delimited string
    """
    return ' '.join([token[0] for token in tokens[offset:]])

def tagged_token_gen(tags, tokens_with_offset):
    """
    Find the tag offsets
    """
    token_accum = []
    for token in tokens_with_offset:
        token_accum.append(token)
        for tag in tags:
            tag_text = tag.get('tag')
            if tokens_to_string(token_accum, -1) == tag_text:
                yield TaggedToken(tag, token)
            if len(token_accum) > 1 and tokens_to_string(token_accum, -2) == tag_text:
                yield TaggedToken(tag, merge_tokens(token_accum[-2:]))
            if len(token_accum) > 2 and tokens_to_string(token_accum, -3) == tag_text:
                yield TaggedToken(tag, merge_tokens(token_accum[-3:]))

def convert_tags_to_annotations(
        SERVER_URL = "http://54.83.200.115/",
        AUTH = None,
        CKAN_URL = "https://ckan-datastore.s3.amazonaws.com/2013-12-05T16:33:55.912Z/tagging-brainstorm-sheet1.csv"
    ):
    """
    Find all the occurances of resources tags in the resource text and 
    create annotations in the annotation database.
    """
    if AUTH is None: AUTH=(raw_input("username: "), raw_input("password: "))
    print "Fetching resources from the portfolio manager..."
    r = requests.request("GET", SERVER_URL + "resources/", auth=AUTH)
    resources_text = r.text
    print "Resources downloaded from server"
    resources = json.loads(resources_text)
    print "Loading resources..."
    for resource in resources:
        #I html parse the resource to handle some of the issues with html entities and tags.
        #Content is nested in a body tag to preserve the leading spaces
        doc = lhtml.fromstring('<body>' + resource.get('content') + '</body>')
        #lxml has a few ways to generate strings. I'm using this one
        #because it doesn't replace apothophies and arrows with unicode points.
        text = lhtml.tostring(doc, method='text', encoding='unicode')
        #This replaces the non-breaking space code points,
        #there are probably others I'm missing.
        text = text.replace(u"\xa0", u" ")
        resource['content'] = text
        

    print "Fetching tags..."
    tags = []
    with contextlib.closing(urllib2.urlopen(CKAN_URL)) as raw_csv:
        category = ''
        for line in raw_csv.read().split('\n'):
            if line:
                new_category, tag = line.split(',')
                if new_category:
                    category = new_category.lower()
                if tag and not tag in tags:
                    tags.append(tag)


    for resource in resources:
        # Gather up all the tags that might be present in the resource text
        uri = SERVER_URL + 'annotatableResources/' + resource.get('_id')
        print "Annotating: " + uri
        
        all_resource_tags = []
        for key, value in resource.get('tags', {}).items():
            if value.get('removed', False):
                continue
            all_resource_tags.append({
                'tag' : key,
                'addedBy' : value.get('addedBy'),
                'dateAdded' : str(dateutil.parser.parse(value.get('dateAdded'))),
                'resourceId' : resource.get('_id')
            })
        
        for tag in tags:
            duplicates = [t for t in all_resource_tags if t.get('tag') == tag]
            if len(duplicates) > 0: continue
            all_resource_tags.append({
                'tag' : tag,
                'addedBy' : 'annotabot'
            })
    
        ### Upload annotations to the portfolio manager
        tokens_with_offset = token_with_offset_gen(resource.get('content'))    
        for tagged_token in tagged_token_gen(all_resource_tags, tokens_with_offset):
            text = tagged_token.tag.get('tag')
            if tagged_token.tag.get('addedBy') == 'annotabot':
                text = 'autotagged ' + text
            data = {
                'text' : text,
                'quote' : tagged_token.tag.get('tag'),
                'ranges' : [{
                    'start' : "",
                    'end' : "",
                    'startOffset' : tagged_token.token[1][0],
                    'endOffset' : tagged_token.token[1][1]
                }],
                'uri' : uri,
                'addedBy' : tagged_token.tag.get('addedBy'),
                'client' : 'import-script-0.0.0'
            }
            #print json.dumps(data)
            #I ran into a bug usint requests lib: https://github.com/kennethreitz/requests/issues/1984
            #so I'm using urllib here instead.
            req = urllib2.Request("http://54.83.200.115/annotator/annotations", json.dumps(data), {'Content-Type': 'application/json'})
            req.add_header('Authorization', 'Basic ' + base64.urlsafe_b64encode(AUTH[0]+':'+AUTH[1]))
            open_req = urllib2.urlopen(req)
            print json.loads(open_req.read()).get('quote')

if __name__ == "__main__":
    convert_tags_to_annotations()

    