# cfmlstats
Parses your CFML code base and gives you stats

## Running it

Clone this repository from github:

	git clone https://github.com/foundeo/cfmlstats.git

Next you need to install the dependencies it requires (cfmlparser)[https://github.com/foundeo/cfmlparser] and (cfdocs)[https://github.com/foundeo/cfdocs]. The easiest way to install them is to use (CommandBox)[https://www.ortussolutions.com/products/commandbox] and run the following from the root:

	box install

Now either place the directory anywhere under a web root, or use a commandbox embedded CFML server, like this:

	box server start

## What kind of stats does it produce?

* Number of CFML Files in directory
* Lines of Code
* Number of Script vs Tag CFCs
* Number of Application.cfc or Application.cfm files
* List of CFML tags used sorted by usage count
* List of CFML functions used sorted by usage count
* Identifies Deprecated / Removed tag or function use (relies on the (cfdocs.org)[https://cfdocs.org/] repository)
* Minumum Version of ColdFusion for tags / functions
* Other handy info