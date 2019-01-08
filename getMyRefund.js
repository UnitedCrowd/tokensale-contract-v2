// Triggr this function when someone wants to claim extra token which went into vesting due to over purchase

function getMyRefundJS()
{
	if(!web3.isConnected()) {

	  alert("Please connect to Metamask.");
	  return;
	}

	// check network
	var networkID = web3.version.network;	// change this in the future
	var networkName = "Kovan Test Network";	// change this in the future

	if(networkID !== "42")
	{
		alert("Please Switch to the " + networkName);
		return;
	}

	crowdsaleInstance.getMyRefund.estimateGas(function(error, result) {
		if (!error)
		{
			crowdsaleInstance.getMyRefund(function(error, result)
			{
				if (!error)
				{
					// Transaction submitted Successfully
					alert("This is the tx hash: " + result);
					// can open https://kovan.etherscan.io/tx/<result> in a new tab
				}
				else
				{
					if (error.message.indexOf("User denied") != -1)
					{
						alert("You rejected the transaction on Metamask!");
					}
					else
					{
						// some unkonwn error
						alert(error);
					}
				}
			});
		}
		else
		{
			// transaction will fail! So dont execute
			alert("This function cannot be run at this time.");
		}
	});

	return;
}
