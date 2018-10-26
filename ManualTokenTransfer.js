// Trigger this function when admin wants to send manual tokens
// @param beneficiary : address of reciever. e.g : "0xAB63B697EbCfF371b850FC50a7913555A97215fB"
// @param amountOfEtherValue : if you want to sent tokens worth "four" ether, param should be : 4
function manualTokenTransferJS(beneficiary, amountOfEtherValue)
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

	crowdsaleInstance.manualTokenTransfer.estimateGas(beneficiary, amountOfEtherValue, function(error, result) {
		if (!error)
		{
			crowdsaleInstance.manualTokenTransfer(beneficiary, amountOfEtherValue, function(error, result)
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
