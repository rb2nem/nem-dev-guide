+++
prev = "/06-transaction-transfer"
next = "90-snippets"
weight = 80
title = "Debugging"
toc = true
+++
## Debugging REST API requests
The docker environment accompanying this guide provides [mitmweb](http://docs.mitmproxy.org/en/stable/mitmweb.html) to inspect requests sent to
the NIS instance running in the container. This section will show how to use it.

We will send requests to out NIS in the [ruby language](http://www.ruby-lang.org), using the [rest-client gem](http://www.rubydoc.info/github/rest-client/rest-client).
We will try to get the block at the current height, which, as we have already seen, is obtained by sending a POST request to `/block/public/at` with 
a JSON payload telling the height of the block we want to retrieve. 

According to the documentation of rest-client this is done easily. We will do it in the interactive ruby interpreter that can be
started with the command `irb` in the tools container. Once in the interpreter, we type

``` ruby
require 'rest-client'
RestClient.post 'http://localhost:7890/block/at/public', {'height': '243'}
```

This however returns an error message:

```
RestClient::InternalServerError: 500 Internal Server Error
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/abstract_response.rb:223:in `exception_with_response'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/abstract_response.rb:103:in `return!'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:809:in `process_result'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:725:in `block in transmit'
	from /usr/lib/ruby/2.3.0/net/http.rb:853:in `start'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:715:in `transmit'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:145:in `execute'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:52:in `execute'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient.rb:71:in `post'
	from (irb):2
	from /usr/bin/irb:11:in `<main>'
```

This error message is not very helpful, so we might want to take a look at the mitmweb page available at [http://localhost:8081](http://localhost:8081) 
after you start containers with the script `ndev` [as explained ealier](/03-setting-up-environment).

Opening Mitmweb in your browser (use Firefox if you get a blank page in Google Chrome), and selecting the last request in the list,
you should see a page similar to this:
{{< figure src="/images/debugging_mitmweb_overview.png" title="Mitmweb Overview" >}}

The left pane lists the requests it has been intercepted (2 in this case), and
the right pane gives you a detailed view of the request and response headers.
The User-Agent header shows this request has been sent by rest-client to the
host nemdevnis (the container running our NIS instance) with a content type
header `application/x-www-form-urlencoded`.

Clicking on the Response link of the right tab shows this:
{{< figure src="/images/debugging_mitmweb_step1_response.png" title="Response Headers" >}}
This is already mugh more informative. It means our request sent its data in an encoding not supported
by the server.

We can fix this by setting the content type header to json and ensure we send a json payload:
``` ruby
require 'rest-client'
require 'json'
RestClient.post 'http://localhost:7890/block/at/public', {'height': '243'}.to_json, {content_type: :json, accept: :json}
```
This still yields an error in  ruby, which is not much clearer:
```
RestClient::InternalServerError: 500 Internal Server Error
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/abstract_response.rb:223:in `exception_with_response'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/abstract_response.rb:103:in `return!'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:809:in `process_result'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:725:in `block in transmit'
	from /usr/lib/ruby/2.3.0/net/http.rb:853:in `start'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:715:in `transmit'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:145:in `execute'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient/request.rb:52:in `execute'
	from /var/lib/gems/2.3.0/gems/rest-client-2.0.2/lib/restclient.rb:71:in `post'
	from (irb):10
	from /usr/bin/irb:11:in `<main>'
```

{{< figure src="/images/debugging_mitmweb_response_property_value.png" title="Wrong Property Value Response" >}}
It reports a incompatible value for the property height. Looking at the request details, we have:
{{< figure src="/images/debugging_mitmweb_request_details.png" title="Request details" >}}
We see at the bottom that the text passed as value is valid JSON. If we don't see what's wrong here, 
we can send the same request with a tool that gave a succesful response. In our case, this is [a request
we already sent](/04-blockchain-requests/#getting-a-block-at-height-post-block-at-public) with httpie.
We know that issuing the command `http :7890/block/at/public height:=243` yields a successful result.
Let's just issue that command and look at the request headers. Here are the details of the request sent by
httpie:
{{< figure src="/images/debugging_mitmweb_httpie_request.png" title="Successful request with httpie" >}}
Did you spot the difference? Httpie sent
``` json
{
    "height": 243
}
```
while with rest-client we sent:
``` json
{
    "height": "243"
}
```
We send the value of the `height` property as a string, whereas it should be an integer.
Let's see if this fixes our problem:
``` ruby
require 'rest-client'
require 'json'
resp=RestClient.post 'http://localhost:7890/block/at/public', {'height': 243}.to_json, {content_type: :json, accept: :json}
=> <RestClient::Response 200 "{\"timeStamp...">
```
Sure enough! We now successfully debugged and sent a request from Ruby.
