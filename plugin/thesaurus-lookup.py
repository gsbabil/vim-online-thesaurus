#!/usr/bin/python

__author__ = "Babil (Golam Sarwar)"
__email__ = "gsbabil@gmail.com"
__version__ = "0.0.2"
__details__ = "Thesaurus.com lookup helper"

import re
import sys
import json
import codecs
import requests
from bs4 import BeautifulSoup

url = "http://www.thesaurus.com/browse/"

if len(sys.argv) > 1:
    regex = re.compile('\ +')
    word = regex.sub('+', sys.argv[1])
    req = requests.get(url + word)
    html = req.content.decode('utf-8', 'ignore')
    soup = BeautifulSoup(html, "html.parser", from_encoding='ascii')
    syn_desc = soup.find(attrs={"class": "synonym-description"})

    print "Main entry:", sys.argv[1]
    if syn_desc:
        txt = syn_desc.find(attrs={"class": "txt"})
        ttl = syn_desc.find(attrs={"class": "ttl"})
        if txt and ttl:
            print "\nDefinition:", txt.get_text(), ttl.get_text()

        relevancy_block = soup.find(attrs={"class":
                                               "relevancy-block"})
        if relevancy_block:
            a_tags = relevancy_block.find_all("a")
            for a in a_tags:
                if a.has_attr('data-category'):
                    json_data = json.loads(a['data-category'])
                    if json_data.has_key('name'):
                        relevancy = json_data['name']
                        synonym = a.span.get_text()
                        print "%s : %s" %(relevancy, synonym)
    else:
        print "\nDefinition:", "(nothing found)"
