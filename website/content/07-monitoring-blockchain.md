+++
prev = "/06-transaction-transfer"
next = "80-debugging"
weight = 70
title = "Monitoring the blockchain"
toc = true
+++
Monitoring the blockchain is possibly an important part of your application on NEM. The most obvious example being
monitoring activities involving your account. Two approaches are possible. 

The first is polling, meaning that regularly
you retrieve the last block and handle it. If your polling interval is significantly smaller than the average block generation
time, you can be sure you will handle all blocks. And if your polling interval is bigger and multiple blocks have been generated
between two polling, you can still request all new blocks in your handler. This approach has downsides, notably that the client
is regularly sending queries, even if activity of interest to the poller occured on the blockchain. This means that the scalability
of this approach is limited. But its development is very easy and might be sufficient in most cases.

The second way is subscribing to notifications from the NIS instance you connect to. This is done with websockets. This is the way it is 
done in the NanoWallet. This is a cleaner approach, but is a bit more complex.

## Active monitoring: the polling approach

The pollign approach is very easy to explain, and it translates immediately in runnable code in any language, expecially if it provides
REST and JSON libraries. Here are the steps to do in a loop:

* retrieve the last block
  * if this is a new block, handle it and remember this was the last block we've seen
  * if this is a block we already handled, wait for x seconds.
* repeat

The number of seconds x we wait (the polling interval) will determine if we will handle all blocks. If it is smaller than the average generation time of a block, 
we can be sure that all blocks will be retrieved at least once by this code. We call this rapid polling in opposition of slow polling. 
An interval of 15 seconds seems safe for rapid polling.

### Rapid polling


It is quite straight-forward to translate that to code, even in a bash script using [httpie](https://httpie.org/) and [jq](https://stedolan.github.io/jq/).
Let's see how this can be done!

First we initialise 2 variables: the monitored address, and the last block seen by the script which is set to 0 at the start of the script:
```
observed_address="TA6XFSJYZYAIYP7FL7X2RL63647FRMB65YC6CO3G"
last_block_analysed=0
```

As we will continually monitor the blockchain, our code will be wrapped in an infinite while loop:

``` bash
while true; do


done
```

In the loop, we retrieve the last block by sending a GET query to `/chain/last-block`, and save the result in variable `block`:
```
block=$(http :7890/chain/last-block)
```

This will retrieve the last block in a json document. Here is an example from the mainnet chain showing the format of the document
retrieved.

{{< httpie "code/monitoring_last_block.html" >}}


Parsing that with jq is easy. The height of the block retrieved is available in the top level property `height`, extract with jq using the
filter `.height`. As the JSON describing the last block is saved in variable `$block`, we can simply pipe it to jq
```
chain_height=$(echo "$block" | jq '.height')
```

The transactions are stored in the top level property named `transactions` as an array value, that can be empty if no transaction is
included in that block. This corresponds to a jq filter `'.transactions[]?`, the question mark indicating that it can be empty.
But we are only interested in the transactions to our address. This means that the  property `recipient` of the transaction should 
hold a value equal to our `$observed_address`.  This corresponds to a filte `select(.recipient=="'$observed_address'")`.
Assigning the transaction select by our filter to a variable `found_recipient` results in this code:
```
found_recipient=$(echo "$block" | jq -r '.transactions[]?|select(.recipient=="'$observed_address'")')
```
That variable will be empty if no transaction involving the monitored address was found. We can use the bash empty string test `[[ -n $variable ]]`
to determine if the block holds a transaction to our monitored address:
``` bash
if [[ -n $found_recipient ]] ; then
  echo "Our monitored address received a transaction!"
else
  echo "Not our observed recipient"
fi
```
 
Putting all this in a script results in this:
``` bash
#!/bin/bash

observed_address="TA6XFSJYZYAIYP7FL7X2RL63647FRMB65YC6CO3G"
last_block_analysed=0
while true; do
    # get last block
    block=$(http :7890/chain/last-block)
    echo "$block"
    chain_height=$(echo "$block" | jq '.height')
    if [[ $last_block_analysed -eq $chain_height ]]; then
        echo "Waiting at $chain_height"
        sleep 15
    else
        last_block_analysed=$chain_height
        found_recipient=$(echo "$block" | jq -r '.transactions[]?|select(.recipient=="'$observed_address'")')
        if [[ -n $found_recipient ]] ; then
          echo "Our monitored address received a transaction!"
        else
          echo "Not our observed recipient"
        fi
    fi
done
```

### Slow polling

If the polling interval is too big, the code has to be prepared to query blocks that were generated during the
polling interval.

* retrieve the last block
  * if this is a block we already handled, wait for x seconds.
  * if this is a new block: 
         * if this is the next expected block, handle it and remember this was the last block we've seen
         * if multiple blocks have been generated since the last block handled, retrieve all these block individually and handle them
* repeat

