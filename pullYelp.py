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
    
    #check the cache file for an existing token
    if (os.path.exists(TOKENCACHE)):
        # read token if cachefile exists
        try:
            with open(TOKENCACHE,'r') as infile:
                token = infile.readline().strip()
                return token
        except IOError:
            print('Error, could not read from {tc}\n'.format(tc=TOKENCACHE))
            sys.exit()
    else:
        # get a new token if it does not
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
        token=response_dict['access_token']
        # print('token = {token}'.format(token=response_dict['access_token']))
        try:
            with open(TOKENCACHE,'w') as tc:
                tc.write('{token}\n'.format(token=thetoken))
        except IOError:
            print('could not write to {tc}'.format(tc=TOKENCACHE))
            sys.exit()
        return token


def pullFromYelp(payload,token):
    searchurl = '{root}v3/businesses/search'.format(root=API_ROOT)
    headers = {'user-agent':'Pete\'s python script','Authorization':'Bearer {tk}'.format(tk=token)}
    
    q = requests.get(searchurl,headers=headers,params=payload)
    
    if q.status_code != requests.codes.ok:
        print('Error, bad authentication request')
        print(q.url)
        print(q.status_code)
        print(q.text)
        sys.exit()
    responsedict = q.json()
    return responsedict
    

def DoStuff():
    
    
    token = GetToken()
    
    # Have a token, now search yelp
    searchurl = '{root}v3/businesses/search'.format(root=API_ROOT)
    
    # categories = ['asianfusion','burgers','barbecue','brasseries','caribbean','chinese',
#     'comfortfood','fishnchips','french','indpak','italian','japanese','korean','kebab',
#     'mediterranean','mexican','noodles','steak','sushi','thai']
    
    cslim = ['chinese','french','burgers','mexican','mideastern','sushi','italian','steak','sushi']
    
    thelim = 50
    hardmax = 1000
    # payload = {'location':'Toronto, On, Ca','sort_by':'rating','limit':thelim,'offset':0}
    payload = {'location':'Toronto, On, Ca','limit':thelim,'offset':0}
    
    Masterdf = None
    for cat in cslim:
        payload['offset'] = 0
        payload['categories'] = {'{ct}'.format(ct=cat)}
        
        responsedict = pullFromYelp(payload,token):
        
        yid = []
        lat = []
        lng = []
        name = []
        rating = []
        reviews = []
        thecat = []
        
        
        total = responsedict['total']
        print ('found total of {t} restaurants that match {cat}'.format(t=total,cat=cat))
        for business in responsedict['businesses']:
            yid.append(business['id'])
            lat.append(business['coordinates']['lattitude'])
            lng.append(business['coordinates']['longitude'])
            name.append(business['name'])
            rating.append(business['rating'])
        print('\n')
  
def main():

    DoStuff()


if __name__ == '__main__':
    main()
