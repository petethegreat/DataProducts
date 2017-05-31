#!/usr/bin/env python

from __future__ import print_function

import sys
import os
import requests
import urllib
from urllib import urlencode
from urllib import quote



# https://github.com/joestump/python-oauth2


# https://github.com/Yelp/yelp-fusion/blob/master/fusion/python/sample.py

API_ROOT = 'https://api.yelp.com/'
CREDENTIALS = 'yelpCredentials.txt'
TOKENCACHE = 'tokenCache.txt'


def GetCredentials():
    fname = CREDENTIALS
    lines = None
    try:
        with open(fname,'r') as infile:
            lines = infile.readlines()
    except IOError:
        print('Error, could not open file {f}'.format(f=fname))
        sys.exit()

    words = lines[1].strip().split()
    thecid = words[0]
    thesecret = words[1]

    return thecid,thesecret

def GetToken():
    theid,thesecret = GetCredentials()

    # send a POST request to get an auth token
    oauthpath='oauth2/token'
    authroot='{ar}{oauth}'.format(ar=API_ROOT,oauth=quote(oauthpath.encode('utf8')))
    payload = {
        'grant_type':'client_credentials',
        'client_id':theid,
        'client_secret':thesecret
    }


    r = requests.post(authroot,data=payload)
    if r.status_code != requests.codes.ok:
        print('Error, bad authentication request')
        print(r.status_code)
        print(r.text)
        sys.exit()

    # request is good.
    # get token info
    response_dict = r.json()
    thetoken=response_dict['access_token']
    # print('token = {token}'.format(token=response_dict['access_token']))
    try:
        with open(TOKENCACHE,'w') as tc:
            tc.write('{token}\n'.format(token=thetoken))
    except IOError:
        print('could not write to {tc}'.format(tc=TOKENCACHE))
        sys.exit()



def DoStuff():
    token = None
    #check the cache file for an existing token
    if (os.path.exists(TOKENCACHE)):
        # read token if cachefile exists
        try:
            with open(TOKENCACHE,'r') as infile:
                token = infile.readline().strip()
        except IOError:
            print('Error, could not read from {tc}\n'.format(tc=TOKENCACHE))
            sys.exit()
    else:
        # get a new token if it does not
        token = GetToken()
    pass







def main():


    DoStuff()







if __name__ == '__main__':
    main()
