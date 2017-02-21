# Status

This gem is no longer working and no longer maintained.

Please see 

* The API documentation: http://doc.2performant.com/
* The PHP wrapper: https://github.com/2Parale/2Performant-php

# Old readme

## 2Performant Ruby API

The API allows you to integrate any 2Performant network in your application.

Its goal is to make sure developers can implement anything that can be done via the web interface using API functions.

The API is RESTful XML over HTTP using all four verbs (GET/POST/PUT/DELETE).

The current implementation is a straight port of the PHP library, so the documentation applies, for the most part, to both libraries.

API documentation can be found at:
http://help.2performant.com/API


## Some Examples

Interacting with 2Performant networks is very easy.


To initialize the object using simple authentication
  
    session = TwoPerformant.new(:simple, {
      :user => 'user',
      :pass => 'password',
    }, 'http://api.yournetwork.com')

To use oauth

    tp = TwoPerformant.new(:oauth, {
      :consumer_token => 'consumer_token',
      :consumer_secret => 'consumer_secret',
      :access_token => 'access_token',
      :access_secret => 'access_secret'
    }, 'http://api.yournetwork.com')


Afterwards you can call any function from the TPerformant class:

    # display the last 6 received messages
    p session.received_messages_list

For details about each API function the documentation can be found at:
http://help.2performant.com/API


## Advanced Applications

You can build advanced applications using the 2Performant API and have them distributed over 2Performant App Store. 

Get Started at: http://apps.2performant.com and http://help.2performant.com/Developers-Area

## Reporting Problems

If you encounters any problems don't hesitate to contact us at:
support (at) 2performant.com
