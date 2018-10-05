pragma solidity ^0.4.25;

contract MultiSigWallet
{
	address private owner;
	mapping(address => uint256) private owners;

	uint256 private MIN_SIGNATURES;
	uint256 private OWNER_COUNT;
	uint256 private _transactionIdx;

	struct Transaction
	{
		address from;
		address to;
		uint256 amount;
		uint256 signatureCount;
		mapping (address => uint256) signatures;
	}

	mapping (uint256 => Transaction) private _transactions;
	uint256[] private _pendingTransactions;

	event DepositFunds(address from, uint256 amount);
	event TransactionCreated(address from, address to, uint256 amount, uint256 transactionId);
	event TransactionCompleted(address from, address to, uint256 amount, uint256 transactionId);
	event TransactionSigned(address by, uint256 transactionId);

	modifier onlyOwner()
	{
		require(msg.sender == owner);
		_;
	}

	modifier onlyValidOwner()
	{
		require(owners[msg.sender] == 1);
		_;
	}

	constructor(address _owner) public
	{
		owner = _owner;
		owners[owner] = 1;
		MIN_SIGNATURES = 1;
		OWNER_COUNT = 1;
	}

	function addOwner(address _owner) onlyOwner public
	{
		owners[_owner] = 1;
		OWNER_COUNT++;
		MIN_SIGNATURES = (OWNER_COUNT + 1)/2;
	}

	function removeOwner(address _owner) onlyOwner public
	{
		require (_owner != owner);
		owners[_owner] = 0;
		OWNER_COUNT--;
		MIN_SIGNATURES = (OWNER_COUNT + 1)/2;
	}

	function () public payable
	{
		emit DepositFunds(msg.sender, msg.value);
	}

	function withdraw(uint256 amount) onlyValidOwner public
	{
		transferTo(msg.sender, amount);
	}

	function transferTo(address to, uint256 amount) onlyValidOwner public
	{
		require(address(this).balance >= amount);
		uint256 transactionId = _transactionIdx++;

		Transaction memory transaction;
		transaction.from = msg.sender;
		transaction.to = to;
		transaction.amount = amount;
		transaction.signatureCount = 0;

		_transactions[transactionId] = transaction;
		_pendingTransactions.push(transactionId);

		emit TransactionCreated(msg.sender, to, amount, transactionId);
	}

	function getPendingTransactions() view onlyValidOwner public returns (uint256[])
	{
		return _pendingTransactions;
	}

	function getPendingTransactionDetail(uint256 _transactionId) view onlyValidOwner public returns (address from, address to, uint256 amount, uint256 signatureCount)
	{
		from = _transactions[_transactionId].from;
		to = _transactions[_transactionId].to;
		amount = _transactions[_transactionId].amount;
		signatureCount = _transactions[_transactionId].signatureCount;
	}

	function signTransaction(uint256 transactionId) onlyValidOwner public
	{

		Transaction storage transaction = _transactions[transactionId];

		// Transaction must exist
		require(0x0 != transaction.from);
		// Creator cannot sign the transaction
		require(msg.sender != transaction.from);
		// Cannot sign a transaction more than once
		require(transaction.signatures[msg.sender] != 1);

		transaction.signatures[msg.sender] = 1;
		transaction.signatureCount++;

		emit TransactionSigned(msg.sender, transactionId);

		if (transaction.signatureCount >= MIN_SIGNATURES)
		{
			require(address(this).balance >= transaction.amount);
			transaction.to.transfer(transaction.amount);
			emit TransactionCompleted(transaction.from, transaction.to, transaction.amount, transactionId);
			deleteTransaction(transactionId);
		}
	}

	function deleteTransaction(uint256 transactionId) onlyValidOwner public
	{
		uint256 replace = 0;
		for(uint256 i = 0; i < _pendingTransactions.length; i++)
		{
			if (replace == 1)
			{
				_pendingTransactions[i-1] = _pendingTransactions[i];
			}
			else if (transactionId == _pendingTransactions[i])
			{
				replace = 1;
			}
		}
		if(replace == 1)
		{
			delete _pendingTransactions[_pendingTransactions.length - 1];
			_pendingTransactions.length--;
			delete _transactions[transactionId];
		}
	}

	function walletBalance() constant public returns (uint256)
	{
		return address(this).balance;
	}
}
